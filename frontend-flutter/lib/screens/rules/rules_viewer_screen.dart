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
        data: (rules) => _RulesTable(rules: rules),
      ),
    );
  }
}

class _RulesTable extends StatelessWidget {
  final List<RuleModel> rules;
  const _RulesTable({required this.rules});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            _TableHeader(),
            const Divider(height: 1),
            if (rules.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text('등록된 규정이 없습니다.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rules.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _TableRow(rule: rules[i], formatter: formatter),
              ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('카테고리', style: style)),
          Expanded(flex: 2, child: Text('직급', style: style)),
          Expanded(flex: 2, child: Text('최대 한도', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 3, child: Text('허용 시간', style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final RuleModel rule;
  final NumberFormat formatter;
  const _TableRow({required this.rule, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final timeText = (rule.allowedTimeFrom != null || rule.allowedTimeTo != null)
        ? '${rule.allowedTimeFrom ?? '-'} ~ ${rule.allowedTimeTo ?? '-'}'
        : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(rule.categoryName ?? rule.categoryCode ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Text(rule.position ?? '-', style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              rule.maxAmount != null ? '${formatter.format(rule.maxAmount!)}원' : '-',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              timeText,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
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
