import 'package:flutter/material.dart';

class ReceiptResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  const ReceiptResultScreen({super.key, required this.result});

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default:        return Colors.orange;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'approved': return '✅ 승인';
      case 'rejected': return '❌ 반려';
      default:        return '⏳ 검토 대기';
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = result['results'] as List;
    final succeeded = result['succeeded'] ?? 0;
    final total     = result['total']     ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 결과'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 요약 카드
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '총 $total장 중 $succeeded장 성공',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // 결과 목록
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (ctx, i) {
                final item     = results[i];
                final success  = item['success'] == true;
                final receipt  = item['receipt'];
                final status   = receipt?['status'] ?? 'pending';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: success ? _statusColor(status) : Colors.grey,
                      child: Icon(
                        success ? Icons.receipt : Icons.error,
                        color: Colors.white, size: 18,
                      ),
                    ),
                    title: Text(
                      success
                        ? (receipt?['merchant_name'] ?? '가맹점 인식 실패')
                        : item['filename'] ?? '파일',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: success
                      ? Text(
                          '${receipt?['amount'] ?? 0}원 · ${_statusText(status)}',
                          style: TextStyle(color: _statusColor(status)),
                        )
                      : Text(item['error'] ?? '오류',
                          style: const TextStyle(color: Colors.red)),
                    trailing: success
                      ? Text(_statusText(status),
                          style: TextStyle(color: _statusColor(status)))
                      : null,
                  ),
                );
              },
            ),
          ),

          // 확인 버튼
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('완료'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}