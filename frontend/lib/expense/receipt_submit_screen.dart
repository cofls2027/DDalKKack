import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 💡 금액 콤마(,) 표시를 위해 추가

class ReceiptSubmitScreen extends StatefulWidget {
  // 🌟 1. 하드코딩 제거: 이전 화면(AI 분석)에서 받아올 진짜 데이터 그릇 만들기
  final String merchantName;
  final int amount;
  final String category;
  final String cardType;

  const ReceiptSubmitScreen({
    super.key,
    this.merchantName = '알 수 없는 가맹점',
    this.amount = 0,
    this.category = '미분류',
    this.cardType = '미분류',
  });

  @override
  State<ReceiptSubmitScreen> createState() => _ReceiptSubmitScreenState();
}

class _ReceiptSubmitScreenState extends State<ReceiptSubmitScreen> {
  List<dynamic> _myTrips = [];
  String? _selectedTripId; 

  @override
  void initState() {
    super.initState();
    _fetchMyTrips(); 
  }

  // 🚀 2. 출장 목록도 내 아이디 기반으로 필터링해서 가져오기
  Future<void> _fetchMyTrips() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      // 💡 안드로이드 에뮬레이터 접속 오류 방지를 위해 10.0.2.2 대신 다른 파일들과 동일하게 localhost로 통일
      final url = Uri.parse('http://localhost:3000/api/trips?user_id=$currentUserId');
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
    // 금액에 콤마 찍기 로직
    final formattedAmount = NumberFormat('#,###').format(widget.amount);

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

              // 🌟 3. 하드코딩(할매국밥, 10000) 삭제 및 진짜 데이터 화면 출력
              Text('가맹점: ${widget.merchantName}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Text('금액: $formattedAmount원', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Text('카테고리: ${widget.category} / ${widget.cardType}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),

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
                  const DropdownMenuItem(value: null, child: Text('해당 없음 (일반 지출)')),
                  ..._myTrips.map((trip) {
                    return DropdownMenuItem(
                      value: trip['id'].toString(), 
                      child: Text(trip['trip_name'] ?? '이름 없는 출장'), 
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedTripId = val;
                  });
                },
              ),
              
              const Spacer(), 

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
                    // 🌟 5. 하드코딩된 유저 ID 걷어내고, 현재 로그인한 내 아이디 가져오기!
                    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                    
                    if (currentUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
                      return;
                    }

                    try {
                      final url = Uri.parse('http://localhost:3000/api/expenses');
                      final submitData = {
                        'user_id': currentUserId, // 💡 진짜 로그인 아이디 전송!
                        'company_id': 1,
                        'merchant_name': widget.merchantName, // 💡 받아온 진짜 데이터 전송
                        'amount': widget.amount,              // 💡 받아온 진짜 데이터 전송
                        'category': widget.category,          // 💡 받아온 진짜 데이터 전송
                        'card_type': widget.cardType,
                        'payment_date': DateTime.now().toIso8601String(),
                        'trip_id': _selectedTripId,
                      };

                      final response = await http.post(
                        url,
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode(submitData),
                      );

                      if (response.statusCode == 201 && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 영수증 제출 성공!')));
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint('Error: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🚨 제출 실패')));
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