import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../main.dart';
import 'receipt_result_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  String _cardType  = '회사카드';
  int    _headcount = 1;        // ← 인원수
  bool   _isLoading = false;

  Future<void> _pickImages() async {
    try {
      final images = await _picker.pickMultiImage(imageQuality: 80);
      if (images.isEmpty) return;
      setState(() {
        for (final img in images) {
          if (_selectedImages.length < 10) {
            _selectedImages.add(File(img.path));
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('갤러리 오류: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _takePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image == null) return;
    setState(() => _selectedImages.add(File(image.path)));
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _analyzeAll() async {
    if (_selectedImages.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final result = await apiService.batchUpload(
        _selectedImages,
        _cardType,
        _headcount,   // ← 인원수 전달
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptResultScreen(result: result),
        ),
      );
      setState(() => _selectedImages.clear());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영수증 갤러리'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 카드 종류 선택
          DropdownButton<String>(
            value: _cardType,
            underline: const SizedBox(),
            items: ['회사카드', '정부지원카드', '개인카드']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
            onChanged: (v) => setState(() => _cardType = v!),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 선택된 이미지 그리드
          Expanded(
            child: _selectedImages.isEmpty
              ? const Center(
                  child: Text(
                    '사진을 선택해주세요\n최대 10장까지 가능합니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (ctx, i) => Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(_selectedImages[i], fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2, right: 2,
                        child: GestureDetector(
                          onTap: () => _removeImage(i),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),

          // 하단 영역
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('${_selectedImages.length}/10장 선택됨',
                  style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),

                // 인원수 선택
                Row(
                  children: [
                    const Text('인원수:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _headcount > 1
                        ? () => setState(() => _headcount--)
                        : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$_headcount명',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: _headcount < 20
                        ? () => setState(() => _headcount++)
                        : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 갤러리 / 카메라 버튼
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('갤러리'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('카메라'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 분석 시작 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectedImages.isEmpty || _isLoading ? null : _analyzeAll,
                    icon: _isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.analytics),
                    label: Text(_isLoading ? '분석 중...' : '일괄 분석 시작'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}