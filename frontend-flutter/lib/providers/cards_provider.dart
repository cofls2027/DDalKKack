import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../providers/user_provider.dart';
import '../services/cards_service.dart';

final myCardsProvider = FutureProvider.autoDispose<List<CardModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('로그인이 필요합니다.');

  return ref.watch(cardsServiceProvider).fetchCards(user.companyId);
});
