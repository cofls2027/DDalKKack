import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'receipt_detail_screen.dart';
import 'receipt_submit_screen.dart'; // 💡 방금 만든 영수증 제출 화면 불러오기

// 💡 방금 만든 영수증 제출 화면 불러오기
// 💡 상세 화면 불러오기
// 💡 하단 탭바에서 이동할 출장 화면 불러오기

// 🖥️ 메인 지출 내역 화면 (코틀린의 MainActivity + activity_history.xml 합체 버전)
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
// 💡 1. 필터 상태를 저장할 변수들 (기존 receipts 변수 근처에 추가)
  List<dynamic> _allReceipts = []; // DB에서 가져온 진짜 전체 원본 데이터
  List<dynamic> _filteredReceipts = []; // 화면에 보여줄 필터링된 데이터
  
  String _selectedMonth = '전체 월';
  String _selectedCategory = '전체 카테고리';

class _HistoryScreenState extends State<HistoryScreen> {
  // 💡 2. 필터 버튼을 누를 때마다 데이터를 걸러주는 요술 함수 (클래스 안에 추가)
  void _applyFilters() {
  setState(() {
    _filteredReceipts = _allReceipts.where((item) {
      // 1. 카테고리 필터 (데이터가 없거나 '전체'면 통과!)
      bool matchCategory = _selectedCategory == '전체 카테고리' || 
                           item['category'] == null || // 💡 데이터가 NULL이어도 통과되게 수정
                           item['category'] == _selectedCategory;

      // 2. 월 필터
      bool matchMonth = _selectedMonth == '전체 월';
      if (!matchMonth && item['payment_date'] != null) {
        try {
          DateTime date = DateTime.parse(item['payment_date']);
          String monthStr = '${date.month}월';
          matchMonth = monthStr == _selectedMonth;
        } catch (e) {
          // 날짜 형식이 잘못되었을 경우 일단 포함시킴
          matchMonth = true; 
        }
      } else if (item['payment_date'] == null) {
        // 💡 날짜가 비어있는 옛날 데이터도 '전체 월'일 때는 보여주게 수정
        matchMonth = (_selectedMonth == '전체 월');
      }

      return matchCategory && matchMonth;
    }).toList();
  });
}
  // 💡 1. 더미 데이터 대신 DB에서 가져올 빈 바구니 준비
  List<dynamic> _receipts = [];
  bool _isLoading = true;
  String _selectedCategory = '전체 카테고리';

  @override
  void initState() {
    super.initState();
    _fetchReceipts(); // 화면이 켜지자마자 데이터 가져오기!
  }

  // 🚀 2. DB에서 진짜 데이터 꺼내오기 (null 방어막 추가!)
  // 기존 _fetchReceipts() 함수 내부를 이렇게 바꿔주세요!
  Future<void> _fetchReceipts() async {
    try {
      final data = await Supabase.instance.client
          .from('receipts')
          .select()
          .order('payment_date', ascending: false);

      setState(() {
        _allReceipts = data;
        print('가져온 데이터 개수: ${data.length}'); // 💡 디버그 콘솔에 숫자가 찍히는지 확인!
        _applyFilters();     
        _isLoading = false; // 💡 데이터를 다 가져오면 로딩을 멈추도록 추가
      });
    } catch (e) {
      debugPrint('데이터 불러오기 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // 💡 에러가 발생했을 때도 무한 로딩에 빠지지 않도록 처리
        });
      }
    }
  }

  // 💡 4. 필터링 로직 (DB에서 가져온 진짜 데이터 기준)
  List<dynamic> get filteredData {
    if (_selectedCategory == '전체 카테고리') return _receipts;
    
    return _receipts.where((item) {
      final category = item['category'] ?? '';
      final storeName = item['merchant_name'] ?? '';
      
      if (_selectedCategory == '식대') return category.contains('식대') || storeName.contains('식대');
      if (_selectedCategory == '교통비') return category.contains('교통비') || storeName.contains('택시') || storeName.contains('KTX');
      if (_selectedCategory == '회식비') return category.contains('회식');
      
      return false;
    }).toList();
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
          // 🚀 1. 필터 콤보박스 구역
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                // 🗓️ 1. 월 선택 드롭다운 (12월까지 확장!)
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: _selectedMonth,
                    // 💡 1월부터 12월까지 꽉 채웠습니다.
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
                
                // 📂 2. 카테고리 선택 드롭다운 (매뉴얼 기준 세분화!)
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: _selectedCategory,
                    // 💡 오현님이 정리해주신 8가지 대분류 카테고리를 적용했습니다.
                    items: ['전체 카테고리', '식대', '교통비', '회식비', '접대비', '복리후생비', '숙박비', '비품비', '행사비'].map((e) {
                      return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)); // 글자가 길면 ... 처리
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
          
          // 💡 로딩 중이거나 데이터가 없을 때의 화면 처리
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C3489)))
                // 🚨 수정 1: 옛날 변수 filteredData 대신 _filteredReceipts 로 교체!
                : _filteredReceipts.isEmpty 
                    ? const Center(child: Text('해당하는 내역이 없습니다.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredReceipts.length,
                        itemBuilder: (context, index) {
                          // 🚨 수정 2: 창고(_allReceipts)가 아니라 필터 바구니(_filteredReceipts)에서 꺼내기!
                          final item = _filteredReceipts[index];
                          
                          // DB 컬럼명을 안전하게 변환해서 UI에 매핑 (없으면 기본값)
                          final storeName = item['merchant_name'] ?? '알 수 없는 사용처';
                          final amount = item['amount']?.toString() ?? '0';
                          final date = item['payment_date'] ?? '날짜 없음';
                          final category = item['category'] ?? '분류 없음';
                          final method = item['card_type'] ?? '결제수단 모름';
                          
                          // 아이콘 간단 매칭 로직
                          String icon = "🧾";
                          if (category.contains('식대')) icon = "🍽";
                          if (category.contains('교통비')) icon = "🚕";
                          if (category.contains('회식')) icon = "🍻";

                          return InkWell(
                            onTap: () async {
                              // 💡 1. 클릭한 항목의 데이터를 우리가 만든 Receipt 붕어빵 틀에 예쁘게 담습니다!
                              // 🚀 기존에 있던 'final selectedReceipt = Receipt(...)' 생성 코드 싹 삭제!
                              // DB에서 가져온 item을 통째로 바로 넘깁니다.
                              final isDeleted = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReceiptDetailScreen(receiptData: item),
                                ),
                              );

                              if (isDeleted == true) {
                                _fetchReceipts(); // 삭제 후 돌아오면 목록 다시 불러오기
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

  Widget _buildChip(String label, {String? filterKey}) {
    final key = filterKey ?? label;
    final isSelected = _selectedCategory == key;

    return GestureDetector(
      onTap: () {
        setState(() { _selectedCategory = key; });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEEDFE) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF3C3489) : const Color(0xFF666666),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
