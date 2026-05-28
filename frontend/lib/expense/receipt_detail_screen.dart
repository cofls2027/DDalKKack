import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReceiptDetailScreen extends StatefulWidget {
  final Map<String, dynamic> receiptData;
  const ReceiptDetailScreen({super.key, required this.receiptData});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  late Map<String, dynamic> _currentReceiptData;
  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    _currentReceiptData = Map.from(widget.receiptData);
  }

  Future<void> _showTripMappingDialog() async {
    try {
      final tripUrl = Uri.parse('http://localhost:3000/api/trips');
      final tripResponse = await http.get(tripUrl);
      if (tripResponse.statusCode != 200) throw Exception('출장 목록 실패');
      final List<dynamic> trips = json.decode(tripResponse.body);

      if (!mounted) return;

      final selectedTripId = await showDialog<dynamic>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('출장 연결 / 변경'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: trips.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return ListTile(title: const Text('연결 해제'), onTap: () => Navigator.pop(dialogContext, 'unlink'));
                final trip = trips[index - 1];
                return ListTile(title: Text(trip['trip_name']), onTap: () => Navigator.pop(dialogContext, trip['id']));
              },
            ),
          ),
        ),
      );

      if (selectedTripId != null) {
        final newTripId = (selectedTripId == 'unlink') ? null : selectedTripId;
        final updateUrl = Uri.parse('http://localhost:3000/api/expenses/${_currentReceiptData['id']}');
        final updateResponse = await http.patch(
          updateUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'trip_id': newTripId}),
        );

        if (updateResponse.statusCode == 200) {
          setState(() {
            _currentReceiptData['trip_id'] = newTripId;
            _isModified = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final int targetId = _currentReceiptData['id'];
    final String storeName = _currentReceiptData['merchant_name'] ?? '알 수 없는 가맹점';
    final String category = _currentReceiptData['category'] ?? '미분류';
    final String cardType = _currentReceiptData['card_type'] ?? '결제수단 모름';
    final String purpose = _currentReceiptData['purpose'] ?? '메모 없음';
    final String participants = _currentReceiptData['participants'] ?? '참여자 없음';
    final String status = _currentReceiptData['status'] ?? '대기';
    
    final bool isTripLinked = _currentReceiptData['trip_id'] != null;

    // 금액 콤마 찍기
    String formattedAmount = '0';
    if (_currentReceiptData['amount'] != null) {
      formattedAmount = NumberFormat('#,###').format(_currentReceiptData['amount']);
    }

    // 날짜 포맷팅
    String formattedDate = '날짜 없음';
    if (_currentReceiptData['payment_date'] != null) {
      try {
        DateTime parsedDate = DateTime.parse(_currentReceiptData['payment_date']);
        formattedDate = DateFormat('yyyy. MM. dd HH:mm').format(parsedDate);
      } catch (e) {
        formattedDate = _currentReceiptData['payment_date'];
      }
    }

    // 뒤로가기 처리를 위한 팝스코프 (안드로이드 물리 뒤로가기 버튼 대응)
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _isModified); // 변경사항이 있으면 true를 들고 돌아감
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 80,
          leading: TextButton(
            // 💡 앱바의 뒤로가기 버튼을 누를 때도 변경사항 여부를 들고 돌아갑니다.
            onPressed: () => Navigator.pop(context, _isModified),
            child: const Text('‹ 내역', style: TextStyle(color: Color(0xFF3C3489), fontSize: 16)),
          ),
          title: const Text('상세 보기', style: TextStyle(color: Colors.black, fontSize: 18)),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(storeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                _buildInfoRow('금액', '$formattedAmount원'),
                _buildInfoRow('날짜', formattedDate),
                _buildInfoRow('카테고리', category),
                _buildInfoRow('카드', cardType),
                _buildInfoRow('목적', purpose),
                
                // 🌟 출장 행 (수정 버튼 포함!)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('출장', style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
                      Row(
                        children: [
                          Text(isTripLinked ? '출장 연결됨' : '일반 지출', style: const TextStyle(color: Colors.black, fontSize: 14)),
                          const SizedBox(width: 8),
                          // 💡 연필 아이콘을 누르면 수정 팝업이 뜹니다!
                          InkWell(
                            onTap: _showTripMappingDialog,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: const Color(0xFFEEEDFE), borderRadius: BorderRadius.circular(4)),
                              child: const Icon(Icons.edit, size: 14, color: Color(0xFF3C3489)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('상태', style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFEEEDFE), borderRadius: BorderRadius.circular(16)),
                        child: Text(status, style: const TextStyle(color: Color(0xFF3C3489), fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF888888), fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.black, fontSize: 14)),
        ],
      ),
    );
  }
}