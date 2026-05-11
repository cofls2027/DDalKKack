import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  // 🚀 2. DB 대신 Node.js 서버에서 '내 출장' 목록 싹 가져오는 함수
Future<void> _fetchMyTrips() async {
  try {
    // 안드로이드 에뮬레이터 주소 (서버의 /api/trips 호출)
    final url = Uri.parse('http://10.0.2.2:3000/api/trips');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      
      if (mounted) {
        setState(() {
          _myTrips = data;
        });
      }
    } else {
      throw Exception('서버 응답 에러');
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
                    try {
                      final url = Uri.parse('http://localhost:3000/api/expenses');
                      final submitData = {
                        'user_id': '630c1279-a2bc-401e-9991-52e88e619f67', // TODO: 로그인 연동 시 교체
                        'company_id': 1,
                        'merchant_name': '할매국밥', // TODO: OCR 연동 시 교체
                        'amount': 10000,          // TODO: OCR 연동 시 교체
                        'category': '식대',
                        'card_type': '개인카드',
                        'payment_date': DateTime.now().toIso8601String(),
                        'trip_id': _selectedTripId,
                      };

                      final response = await http.post(
                        url,
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode(submitData),
                      );

                      if (response.statusCode == 201 && context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint('Error: $e');
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