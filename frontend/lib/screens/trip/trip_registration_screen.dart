// trip_registration_screen.dart 파일 내용
import 'package:flutter/material.dart';
import '../../services/api_client.dart';

class TripRegistrationScreen extends StatefulWidget {
  const TripRegistrationScreen({super.key});

  @override
  State<TripRegistrationScreen> createState() => _TripRegistrationScreenState();
}

class _TripRegistrationScreenState extends State<TripRegistrationScreen> {
  final _tripNameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _companionsController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toString().split(' ')[0];
      });
    }
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _purposeController.dispose();
    _companionsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('‹ 홈', style: TextStyle(color: Color(0xFF3C3489), fontSize: 16)),
        ),
        title: const Text('출장 등록', style: TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('출장 정보 입력', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              _buildInputLabel('출장명'),
              _buildTextField('예: 부산 고객사 방문', _tripNameController),
              
              _buildInputLabel('목적'),
              _buildTextField('예: 계약 협의, 현장 점검', _purposeController),
              
              _buildInputLabel('동행인 (선택)'),
              _buildTextField('예: 이지현, 박지훈', _companionsController),
              
              _buildInputLabel('출장 시작일'),
              _buildDateField(context, '연도 - 월 - 일', _startDateController),
              
              _buildInputLabel('출장 종료일'),
              _buildDateField(context, '연도 - 월 - 일', _endDateController),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C54A4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (_tripNameController.text.isEmpty || 
                        _startDateController.text.isEmpty || 
                        _endDateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('출장명과 날짜는 꼭 입력해주세요!')),
                      );
                      return;
                    }

                    try {
                      await apiClient.postJson(
                        '/api/trips',
                        {
                          'trip_name': _tripNameController.text.trim(),
                          'trip_purpose': _purposeController.text.trim(),
                          'trip_companions': _companionsController.text.trim(),
                          'start_date': _startDateController.text.trim(),
                          'end_date': _endDateController.text.trim(),
                        },
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 출장 등록 완료!')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('🚨 등록 실패: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('등록하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEEDFE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소', style: TextStyle(color: Color(0xFF3C3489), fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3C3489), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        readOnly: true, 
        onTap: () => _selectDate(context, controller),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black87, fontSize: 14),
          suffixIcon: const Icon(Icons.calendar_today, size: 18, color: Colors.black87),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3C3489), width: 1.5),
          ),
        ),
      ),
    );
  }
}