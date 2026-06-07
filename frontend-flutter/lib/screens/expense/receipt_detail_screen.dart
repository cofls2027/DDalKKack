import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';

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
      final trips = await apiClient.getList('/api/trips');

      if (!mounted) return;

      final selectedTripId = await showDialog<dynamic>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('출장 연결 / 변경', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            contentPadding: const EdgeInsets.only(top: 16, bottom: 8),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: trips.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: const Icon(Icons.link_off, color: Colors.grey),
                      title: const Text('해당 없음 (일반 지출로 변경)', style: TextStyle(color: Colors.grey)),
                      onTap: () => Navigator.pop(dialogContext, 'unlink'), 
                    );
                  }
                  final trip = trips[index - 1];
                  return ListTile(
                    leading: const Icon(Icons.flight_takeoff, color: Color(0xFF3C3489)),
                    title: Text(trip['trip_name']),
                    onTap: () => Navigator.pop(dialogContext, trip['id']),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext), 
                child: const Text('취소', style: TextStyle(color: Colors.grey)),
              )
            ],
          );
        },
      );

      if (selectedTripId != null && mounted) {
        dynamic newTripId = (selectedTripId == 'unlink') ? null : selectedTripId;

        await apiClient.patchJson(
          '/api/receipts/${_currentReceiptData['id']}',
          {
            'trip_id': newTripId,
          },
        );

        if (!mounted) return;

        setState(() {
          _currentReceiptData['trip_id'] = newTripId;
          _isModified = true; 
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 출장 정보가 성공적으로 변경되었습니다!')),
        );
      }
    } catch (e) {
      debugPrint('출장 변경 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String storeName = _currentReceiptData['merchant_name'] ?? '알 수 없는 가맹점';
    final String category = _currentReceiptData['category'] ?? '미분류';
    final String cardType = _currentReceiptData['card_type'] ?? '결제수단 모름';
    final String purpose = _currentReceiptData['purpose'] ?? '메모 없음';
    final String status = _currentReceiptData['status'] ?? '대기';
    
    final bool isTripLinked = _currentReceiptData['trip_id'] != null;

    String formattedAmount = '0';
    if (_currentReceiptData['amount'] != null) {
      formattedAmount = NumberFormat('#,###').format(_currentReceiptData['amount']);
    }

    String formattedDate = '날짜 없음';
    if (_currentReceiptData['payment_date'] != null) {
      try {
        DateTime parsedDate = DateTime.parse(_currentReceiptData['payment_date']);
        formattedDate = DateFormat('yyyy. MM. dd HH:mm').format(parsedDate);
      } catch (e) {
        formattedDate = _currentReceiptData['payment_date'];
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _isModified); 
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 80,
          leading: TextButton(
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