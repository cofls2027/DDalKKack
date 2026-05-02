import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stats_model.dart';
import '../providers/user_provider.dart';
import '../services/stats_service.dart';

final myStatsProvider = FutureProvider.autoDispose<StatsModel>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('로그인이 필요합니다.');

  final now = DateTime.now();
  return ref.watch(statsServiceProvider).fetchMyStats(
        userId: user.id,
        companyId: user.companyId,
        year: now.year,
        month: now.month,
      );
});
