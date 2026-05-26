import '../../services/api_client.dart';
import 'package:flutter/material.dart';
import 'receipt_detail_screen.dart';
import 'receipt_submit_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _allReceipts = [];
  List<dynamic> _filteredReceipts = [];

  bool _isLoading = true;
  String _selectedMonth = '전체 월';
  String _selectedCategory = '전체 카테고리';

  @override
  void initState() {
    super.initState();
    _fetchReceipts();
  }

  Future<void> _fetchReceipts() async {
    try {
      final data = await apiClient.getList('/api/receipts');

      if (!mounted) return;

      setState(() {
        _allReceipts = data;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      debugPrint('데이터 불러오기 오류: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🚨 내역 불러오기 실패: $e')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredReceipts = _allReceipts.where((item) {
        final category = item['category']?.toString() ?? '';
        final paymentDate = item['payment_date']?.toString();

        final matchCategory =
            _selectedCategory == '전체 카테고리' || category == _selectedCategory;

        var matchMonth = _selectedMonth == '전체 월';

        if (!matchMonth && paymentDate != null && paymentDate.isNotEmpty) {
          try {
            final date = DateTime.parse(paymentDate);
            matchMonth = '${date.month}월' == _selectedMonth;
          } catch (_) {
            matchMonth = true;
          }
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
        title: const Text(
          '내역 조회',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReceiptSubmitScreen(),
                ),
              );

              _fetchReceipts();
            },
            child: const Text(
              '+ 제출',
              style: TextStyle(color: Color(0xFF3C3489)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: _selectedMonth,
                    items: [
                      '전체 월',
                      '1월',
                      '2월',
                      '3월',
                      '4월',
                      '5월',
                      '6월',
                      '7월',
                      '8월',
                      '9월',
                      '10월',
                      '11월',
                      '12월',
                    ].map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      _selectedMonth = val;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: _selectedCategory,
                    items: [
                      '전체 카테고리',
                      '식대',
                      '교통비',
                      '회식비',
                      '접대비',
                      '복리후생비',
                      '숙박비',
                      '비품비',
                      '행사비',
                    ].map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      _selectedCategory = val;
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3C3489),
                    ),
                  )
                : _filteredReceipts.isEmpty
                    ? const Center(
                        child: Text(
                          '해당하는 내역이 없습니다.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredReceipts.length,
                        itemBuilder: (context, index) {
                          final item = _filteredReceipts[index];

                          final storeName =
                              item['merchant_name']?.toString() ?? '알 수 없는 사용처';
                          final amount = item['amount']?.toString() ?? '0';
                          final date =
                              item['payment_date']?.toString() ?? '날짜 없음';
                          final category =
                              item['category']?.toString() ?? '분류 없음';
                          final method =
                              item['card_type']?.toString() ?? '결제수단 모름';

                          var icon = '🧾';
                          if (category.contains('식대')) icon = '🍽';
                          if (category.contains('교통비')) icon = '🚕';
                          if (category.contains('회식')) icon = '🍻';

                          return InkWell(
                            onTap: () async {
                              final isModified = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReceiptDetailScreen(receiptData: item),
                                ),
                              );

                              if (isModified == true) {
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
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEEDFE),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      icon,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          storeName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$category · $method',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$amount원',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        date,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
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