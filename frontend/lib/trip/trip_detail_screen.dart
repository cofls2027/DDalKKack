import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TripDetailScreen extends StatefulWidget {
  final Map<String, dynamic> trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  List<dynamic> _receipts = [];
  bool _isLoading = true;
  int _totalAmount = 0; // 💡 여기서 총 지출 금액 변수를 다시 살려냅니다!

  @override
  void initState() {
    super.initState();
    _fetchTripReceipts();
  }

  Future<void> _fetchTripReceipts() async {
    try {
      final url = Uri.parse('http://localhost:3000/api/trips/${widget.trip['id']}/expenses');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // 💡 가져온 영수증들의 금액을 싹 다 더해주는 계산 로직 복구!
        int total = 0;
        for (var item in data) {
          total += (item['amount'] as num?)?.toInt() ?? 0;
        }

        if (mounted) {
          setState(() { 
            _receipts = data; 
            _totalAmount = total; // 계산된 총합을 변수에 쏙!
            _isLoading = false; 
          });
        }
      } else {
        throw Exception('서버 응답 에러');
      }
    } catch (e) {
      debugPrint('출장 영수증 에러: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripName = widget.trip['trip_name'] ?? '출장명 없음';
    final startDate = widget.trip['start_date'] ?? '?';
    final endDate = widget.trip['end_date'] ?? '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('출장 상세 내역', style: TextStyle(color: Colors.black, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C3489)))
          : Column(
              children: [
                // 1. 상단: 출장 요약 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tripName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text('$startDate ~ $endDate', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEDFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('총 지출 금액', style: TextStyle(color: Color(0xFF3C3489), fontWeight: FontWeight.bold)),
                            Text('$_totalAmount원', style: const TextStyle(color: Color(0xFF3C3489), fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),

                // 2. 하단: 이 출장에서 쓴 영수증 리스트
                Expanded(
                  child: _receipts.isEmpty
                      ? const Center(child: Text('아직 등록된 영수증이 없습니다.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _receipts.length,
                          itemBuilder: (context, index) {
                            final item = _receipts[index];
                            final storeName = item['merchant_name'] ?? '알 수 없는 가맹점';
                            final amount = item['amount'] ?? 0;
                            final date = item['payment_date'] ?? '날짜 없음';
                            final category = item['category'] ?? '미분류';

                            // 날짜 깔끔하게 자르기 (예: 2026-05-11T... -> 2026-05-11)
                            String displayDate = date;
                            if (date.contains('T')) {
                              displayDate = date.split('T')[0];
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text(category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('$amount원', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text(displayDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}