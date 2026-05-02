import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/rule_model.dart';
import '../../providers/rules_provider.dart';

class RulesViewerScreen extends ConsumerWidget {
  const RulesViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(myRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('규정 확인'),
        centerTitle: true,
      ),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(myRulesProvider),
        ),
        data: (rules) => rules.isEmpty
            ? const Center(child: Text('등록된 규정이 없습니다.', style: TextStyle(color: Colors.grey)))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: rules.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _RuleCard(rule: rules[i]),
              ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final RuleModel rule;
  const _RuleCard({required this.rule});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    final policy = rule.policyData;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.policy_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  rule.ruleName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (policy.mealLimit != null)
              _PolicyRow(
                icon: Icons.restaurant,
                label: '식대 한도',
                value: '${formatter.format(policy.mealLimit!)}원',
              ),
            if (policy.transportLimit != null)
              _PolicyRow(
                icon: Icons.directions_car,
                label: '교통비 한도',
                value: '${formatter.format(policy.transportLimit!)}원',
              ),
            if (policy.allowedHours != null)
              _PolicyRow(
                icon: Icons.access_time,
                label: '허용 시간',
                value: policy.allowedHours!,
              ),
            if (policy.bannedItems.isNotEmpty)
              _BannedItemsRow(items: policy.bannedItems),
            if (policy.mealLimit == null &&
                policy.transportLimit == null &&
                policy.allowedHours == null &&
                policy.bannedItems.isEmpty)
              const Text('규정 내용이 없습니다.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _PolicyRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

class _BannedItemsRow extends StatelessWidget {
  final List<String> items;
  const _BannedItemsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.block, size: 18, color: Colors.red),
          const SizedBox(width: 8),
          const Text('금지 항목', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const Spacer(),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: items
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(item, style: const TextStyle(fontSize: 12, color: Colors.red)),
                    ))
                .toList(),
          ),
        ],
      ),
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
