import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptSubmitScreen extends StatefulWidget {
  const ReceiptSubmitScreen({super.key});

  @override
  State<ReceiptSubmitScreen> createState() => _ReceiptSubmitScreenState();
}

class _ReceiptSubmitScreenState extends State<ReceiptSubmitScreen> {
  // 💡 1. 내 출장 목록을 담을 바구니와, 선택된 출장 ID를 저장할 변수
  List<dynamic> _myTrips = [];
  String? _selectedTripId; // 아무것도 선택 안 하면 null (일반 지출)

  @override
  void initState() {
    super.initState();
    _fetchMyTrips(); // 화면 켜지자마자 출장 목록 가져오기!
  }

  // 🚀 2. DB에서 '내 출장' 목록 싹 가져오는 함수
  Future<void> _fetchMyTrips() async {
    try {
      final data = await Supabase.instance.client
          .from('trips')
          .select('id, trip_name') // 💡 콤보박스에 쓸 id와 이름만 쏙 빼옵니다
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _myTrips = data;
        });
      }
    } catch (e) {
      debugPrint('출장 목록 불러오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('영수증 제출', style: TextStyle(color: Colors.black, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
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
              const Text('지출 상세 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // (나중에 여기에 가맹점, 금액, 카테고리 입력칸이 들어옵니다!)
              const Text('가맹점: 할매국밥 (AI 자동입력 테스트)'),
              const SizedBox(height: 12),
              const Text('금액: 10,000원 (AI 자동입력 테스트)'),
              const SizedBox(height: 24),

              // 🌟 3. 핵심! 출장 매핑 콤보박스 (Dropdown)
              const Text('출장 연결 (선택)', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedTripId,
                hint: const Text('관련 출장을 선택하세요'),
                items: [
                  // 1번 옵션: 일반 지출일 경우
                  const DropdownMenuItem(
                    value: null,
                    child: Text('해당 없음 (일반 지출)'),
                  ),
                  // 2번 옵션: DB에서 가져온 출장 목록을 쭈루룩 펼쳐줍니다
                  ..._myTrips.map((trip) {
                    return DropdownMenuItem(
                      value: trip['id'].toString(), // DB의 고유 id
                      child: Text(trip['trip_name'] ?? '이름 없는 출장'), // 화면에 보이는 글자
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedTripId = val;
                  });
                },
              ),
              
              const Spacer(), // 밑으로 버튼 밀어내기

              // 🚀 4. 최종 제출 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C54A4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    // 💡 여기에 실제 DB 전송 로직을 넣습니다!
                    try {
                      await Supabase.instance.client.from('receipts').insert({
                        // 🚨 주의: 아까 출장 등록할 때 쓰셨던 '진짜 유저 UUID'와 '회사 ID'를 똑같이 넣어주세요!
                        'user_id': '048def2e-5ff2-480d-a659-c12d18fa7ed8', 
                        'company_id': 1, 
                        
                        // 임시 하드코딩 데이터 (나중에 AI 담당자가 주는 데이터로 교체될 부분)
                        'merchant_name': '할매국밥', 
                        'amount': 10000,
                        'category': '식대', 
                        'card_type': '개인카드',
                        'payment_date': DateTime.now().toIso8601String(), // 오늘 날짜로 임시 세팅
                        
                        // ✨ 대망의 출장 매핑 데이터! (선택 안 했으면 null이 들어감)
                        'trip_id': _selectedTripId, 
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 영수증 제출 완벽 성공! (출장 연결됨)')),
                        );
                        Navigator.pop(context); // 💡 제출 완료 후 내역 화면으로 자동 복귀!
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('🚨 제출 실패: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('제출하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}