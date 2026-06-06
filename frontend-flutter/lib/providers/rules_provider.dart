import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rule_model.dart';
import '../providers/user_provider.dart';
import '../services/rules_service.dart';

final myRulesProvider = FutureProvider.autoDispose<List<RuleModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('로그인이 필요합니다.');

  return ref.watch(rulesServiceProvider).fetchRules(user.companyId);
});
