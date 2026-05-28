import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'receipt_detail_screen.dart';

// 🖥️ 메인 지출 내역 화면
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 💡 1. 모든 변수는 반드시 클래스 '안쪽'에 있어야 합니다!
  List<dynamic> _receipts = [];         // 서버에서 가져온 원본 데이터를 담을 창고
  List<dynamic> _filteredReceipts = []; // 화면에 실제로 보여줄 진열대 (필터링 완료된 데이터)
  
  bool _isLoading = true;
  String _selectedMonth = '전체 월';
  String _selectedCategory = '전체 카테고리';

  @override
  void initState() {
    super.initState();
    _fetchReceipts(); // 화면 켜지자마자 데이터 가져오기!
  }

  // 🚀 DB에서 진짜 데이터 꺼내오기 (Node.js API + 내 아이디 필터링)
  Future<void> _fetchReceipts() async { 
    setState(() { _isLoading = true; });

    try {
      // 🌟 로그인한 내 아이디 가져오기
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      // 🌟 주소 뒤에 '?user_id=내아이디' 붙여서 쏘기!
      final url = Uri.parse('http://localhost:3000/api/expenses?user_id=$currentUserId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _receipts = data; 
          _isLoading = false;
        });
        _applyFilters(); 
      } else {
        throw Exception('서버 응답 에러');
      }
    } catch (e) {
      debugPrint('내역 조회 에러: $e');
      setState(() { _isLoading = false; });
    }
  }

  // 💡 콤보박스를 누를 때마다 진열대를 새로 세팅해 주는 요술 함수
  // 💡 콤보박스를 누를 때마다 진열대를 새로 세팅해 주는 요술 함수
  // 💡 콤보박스를 누를 때마다 진열대를 새로 세팅해 주는 요술 함수
  void _applyFilters() {
    setState(() {
      _filteredReceipts = _receipts.where((item) {
        // 1. 🌟 정교한 카테고리 필터
        bool matchCategory = _selectedCategory == '전체 카테고리' || item['category'] == null;
        
        if (!matchCategory && item['category'] != null) {
          String dbCategory = item['category'].toString();
          
          if (_selectedCategory == '식대') {
            // '회식'이라는 단어가 안 들어간 진짜 '식대'나 '식비'만 인정! (분리)
            matchCategory = (dbCategory.contains('식대') || dbCategory.contains('식비')) && !dbCategory.contains('회식');
          } else if (_selectedCategory == '회식비') {
            matchCategory = dbCategory.contains('회식');
          } else if (_selectedCategory == '교통비') {
            matchCategory = dbCategory.contains('교통');
          } else if (_selectedCategory == '숙박비') {
            matchCategory = dbCategory.contains('숙박');
          } else if (_selectedCategory == '비품비') {
            matchCategory = dbCategory.contains('비품') || dbCategory.contains('소모품');
          } else if (_selectedCategory == '복리후생비') {
            matchCategory = dbCategory.contains('복리후생'); // '비' 글자 빼고 매칭!
          } else if (_selectedCategory == '접대비') {
            matchCategory = dbCategory.contains('접대');
          } else if (_selectedCategory == '행사비') {
            matchCategory = dbCategory.contains('행사');
          } else {
            matchCategory = (dbCategory == _selectedCategory);
          }
        }

        // 2. 월 필터 (이전과 동일)
        bool matchMonth = _selectedMonth == '전체 월';
        if (!matchMonth && item['payment_date'] != null) {
          try {
            DateTime date = DateTime.parse(item['payment_date']);
            String monthStr = '${date.month}월';
            matchMonth = monthStr == _selectedMonth;
          } catch (e) {
            matchMonth = true; 
          }
        } else if (item['payment_date'] == null) {
          matchMonth = (_selectedMonth == '전체 월');
        }

        return matchCategory && matchMonth;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 80,
        title: const Text('내역 조회', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      
      body: Column(
        children: [
          // 🚀 필터 콤보박스 구역
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: _selectedMonth,
                    items: ['전체 월', '1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'].map((e) {
                      return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedMonth = val!);
                      _applyFilters(); 
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: _selectedCategory,
                    items: ['전체 카테고리', '식대', '교통비', '회식비', '접대비', '복리후생비', '숙박비', '비품비', '행사비'].map((e) {
                      return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategory = val!);
                      _applyFilters(); 
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 💡 화면 그리기 구역
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C3489)))
                : _filteredReceipts.isEmpty 
                    ? const Center(child: Text('해당하는 내역이 없습니다.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredReceipts.length,
                        itemBuilder: (context, index) {
                          // 데이터 꺼내기
                          final item = _filteredReceipts[index];
                          
                          // 변수 매핑 (null 안전하게 처리)
                          final storeName = item['merchant_name'] ?? '알 수 없는 사용처';
                          final amount = item['amount']?.toString() ?? '0';
                          
                          // 날짜 파싱 로직 (예: 2026-05-04T10:33... -> 2026-05-04)
                          String date = '날짜 없음';
                          if (item['payment_date'] != null) {
                             try {
                               DateTime parsedDate = DateTime.parse(item['payment_date']);
                               date = "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
                             } catch(e) {
                               date = item['payment_date'].toString().split('T')[0];
                             }
                          }
                          
                          final category = item['category'] ?? '분류 없음';
                          final method = item['card_type'] ?? '결제수단 모름';
                          
                          String icon = "🧾"; // 기본 아이콘
                          
                          if (category.contains('회식')) icon = "🍻"; // 회식을 가장 먼저 확인!
                          else if (category.contains('식대') || category.contains('식비')) icon = "🍽";
                          else if (category.contains('교통')) icon = "🚕";
                          else if (category.contains('숙박')) icon = "🏨";
                          else if (category.contains('비품') || category.contains('소모품')) icon = "📎";
                          else if (category.contains('복리후생')) icon = "🎁";
                          else if (category.contains('접대')) icon = "🤝";
                          else if (category.contains('행사')) icon = "🎉";

                          return InkWell(
                            onTap: () async {
                              final isDeleted = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReceiptDetailScreen(receiptData: item),
                                ),
                              );

                              if (isDeleted == true) {
                                _fetchReceipts(); 
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEEDFE),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(icon, style: const TextStyle(fontSize: 18)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Text('$category · $method', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('$amount원', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
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