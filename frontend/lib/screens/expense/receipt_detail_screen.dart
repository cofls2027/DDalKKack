import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final Map<String, dynamic> receiptData;

  const ReceiptDetailScreen({super.key, required this.receiptData});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  // 💡 DB에서 변경된 데이터를 화면에 바로바로 반영하기 위한 바구니
  late Map<String, dynamic> _currentReceiptData;
  bool _isModified = false; // 출장이 변경되었는지 체크!

  @override
  void initState() {
    super.initState();
    // 처음 넘어온 데이터를 바구니에 담습니다.
    _currentReceiptData = Map.from(widget.receiptData); 
  }

  // 🚀 핵심: 출장 목록을 불러오고 팝업창을 띄우는 함수!
  Future<void> _showTripMappingDialog() async {
    try {
      // 1. DB에서 내 출장 목록 싹 가져오기
      final trips = await Supabase.instance.client
          .from('trips')
          .select('id, trip_name')
          .order('created_at', ascending: false);

      if (!mounted) return;

      // 2. 팝업창(Dialog) 띄우기
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
                  // 첫 번째 칸은 '연결 해제' 옵션
                  if (index == 0) {
                    return ListTile(
                      leading: const Icon(Icons.link_off, color: Colors.grey),
                      title: const Text('해당 없음 (일반 지출로 변경)', style: TextStyle(color: Colors.grey)),
                      onTap: () => Navigator.pop(dialogContext, 'unlink'), 
                    );
                  }
                  // 나머지는 내 출장 목록
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
                onPressed: () => Navigator.pop(dialogContext), // 취소하면 null 반환
                child: const Text('취소', style: TextStyle(color: Colors.grey)),
              )
            ],
          );
        },
      );

      // 3. 사용자가 출장을 선택했다면? -> DB 업데이트!
      if (selectedTripId != null && mounted) {
        dynamic newTripId = (selectedTripId == 'unlink') ? null : selectedTripId;

        // DB 진짜로 수정하기
        await Supabase.instance.client
            .from('receipts')
            .update({'trip_id': newTripId})
            .eq('id', _currentReceiptData['id']);

        // 화면 갱신하기
        setState(() {
          _currentReceiptData['trip_id'] = newTripId;
          _isModified = true; // 변경되었다고 도장 쾅!
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