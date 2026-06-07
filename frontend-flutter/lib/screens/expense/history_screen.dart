import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import 'receipt_detail_screen.dart';

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

  final List<String> _months = const [
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
  ];

  final List<String> _categories = const [
    '전체 카테고리',
    '식대',
    '교통비',
    '회식비',
    '접대비',
    '복리후생비',
    '숙박비',
    '비품비',
    '행사비',
  ];

  @override
  void initState() {
    super.initState();
    _fetchReceipts();
  }

  Future<void> _fetchReceipts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await apiClient.getList('/api/expenses?user_id=62280fd8-2cae-4e33-9827-b1d04e1493a6');

      if (!mounted) return;

      setState(() {
        _allReceipts = data;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      debugPrint('내역 불러오기 오류: $e');

      if (!mounted) return;

      setState(() {
        _allReceipts = [];
        _filteredReceipts = [];
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

  String _formatAmount(dynamic value) {
    final amount = int.tryParse(value?.toString() ?? '0') ?? 0;
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}원';
  }

  String _formatDate(dynamic value) {
    final raw = value?.toString();

    if (raw == null || raw.isEmpty) {
      return '날짜 없음';
    }

    try {
      final date = DateTime.parse(raw);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  String _iconForCategory(String category) {
    if (category.contains('식대')) return '🍽';
    if (category.contains('교통')) return '🚕';
    if (category.contains('회식')) return '🍻';
    if (category.contains('숙박')) return '🏨';
    if (category.contains('접대')) return '🤝';
    return '🧾';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '내역 조회',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // 🌟 오현님 요청대로 여기서 '+ 제출' 버튼만 정확하게 삭제했습니다.
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
                    initialValue: _selectedMonth,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(
                          month,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      _selectedMonth = value;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      _selectedCategory = value;
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
                    : RefreshIndicator(
                        onRefresh: _fetchReceipts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredReceipts.length,
                          itemBuilder: (context, index) {
                            final item = _filteredReceipts[index];

                            final storeName =
                                item['merchant_name']?.toString() ??
                                    item['merchant']?.toString() ??
                                    '알 수 없는 사용처';

                            final amount = _formatAmount(item['amount']);
                            final date = _formatDate(item['payment_date']);
                            final category =
                                item['category']?.toString() ?? '분류 없음';
                            final method =
                                item['card_type']?.toString() ?? '결제수단 모름';
                            final status =
                                item['status']?.toString() ?? 'pending';

                            final icon = _iconForCategory(category);

                            return InkWell(
                              onTap: () async {
                                final isModified = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReceiptDetailScreen(
                                      receiptData: item,
                                    ),
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
                                      width: 42,
                                      height: 42,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEEDFE),
                                        borderRadius: BorderRadius.circular(8),
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
                                          const SizedBox(height: 4),
                                          Text(
                                            status,
                                            style: const TextStyle(
                                              color: Color(0xFF3C3489),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          amount,
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
          ),
        ],
      ),
    );
  }
}