import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/stats_model.dart';
import '../../providers/stats_provider.dart';

class MyStatsScreen extends ConsumerWidget {
  const MyStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(myStatsProvider);
    final now = DateTime.now();
    final title = '${now.year}년 ${now.month}월 내 통계';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: e.toString(), onRetry: () => ref.invalidate(myStatsProvider)),
        data: (stats) => _StatsBody(stats: stats),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final StatsModel stats;
  const _StatsBody({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TotalAmountCard(amount: stats.totalAmount),
        const SizedBox(height: 16),
        _SectionCard(
          title: '카테고리별 지출',
          child: _CategoryBarChart(categoryStats: stats.categoryStats),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '카드 종류별 건수',
          child: _CardTypeStats(cardTypeStats: stats.cardTypeStats),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '승인 현황',
          child: _StatusStats(statusStats: stats.statusStats),
        ),
      ],
    );
  }
}

class _TotalAmountCard extends StatelessWidget {
  final int amount;
  const _TotalAmountCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '이번 달 승인 지출',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${formatter.format(amount)}원',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _CategoryBarChart extends StatelessWidget {
  final Map<String, int> categoryStats;
  const _CategoryBarChart({required this.categoryStats});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    final maxVal = categoryStats.values.fold(0, (a, b) => a > b ? a : b);

    if (categoryStats.isEmpty) {
      return const Center(child: Text('데이터가 없습니다.', style: TextStyle(color: Colors.grey)));
    }

    return Column(
      children: kCategories.map((cat) {
        final val = categoryStats[cat] ?? 0;
        final ratio = maxVal > 0 ? val / maxVal : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Text(cat, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                val > 0 ? '${formatter.format(val)}원' : '-',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CardTypeStats extends StatelessWidget {
  final Map<String, int> cardTypeStats;
  const _CardTypeStats({required this.cardTypeStats});

  @override
  Widget build(BuildContext context) {
    if (cardTypeStats.isEmpty) {
      return const Center(child: Text('데이터가 없습니다.', style: TextStyle(color: Colors.grey)));
    }
    return Row(
      children: kCardTypes.map((type) {
        final count = cardTypeStats[type] ?? 0;
        return Expanded(
          child: Column(
            children: [
              Text(
                '$count건',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(type, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatusStats extends StatelessWidget {
  final Map<String, int> statusStats;
  const _StatusStats({required this.statusStats});

  @override
  Widget build(BuildContext context) {
    const items = [
      {'key': 'approved', 'label': '승인', 'color': Colors.green},
      {'key': 'pending', 'label': '검토중', 'color': Colors.orange},
      {'key': 'rejected', 'label': '반려', 'color': Colors.red},
    ];

    return Row(
      children: items.map((item) {
        final count = statusStats[item['key']] ?? 0;
        final color = item['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Text(
                  '$count건',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Text(item['label'] as String, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
