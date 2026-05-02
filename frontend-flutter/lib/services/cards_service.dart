import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/card_model.dart';

class CardsService {
  Future<List<CardModel>> fetchCards(int companyId) async {
    final uri = Uri.parse('$kApiBaseUrl/cards').replace(queryParameters: {
      'company_id': companyId.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? '카드 목록 조회에 실패했습니다.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => CardModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final cardsServiceProvider = Provider<CardsService>((ref) => CardsService());
