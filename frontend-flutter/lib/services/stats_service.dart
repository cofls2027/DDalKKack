import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/stats_model.dart';

class StatsService {
  Future<StatsModel> fetchMyStats({
    required int userId,
    required int companyId,
    required int year,
    required int month,
  }) async {
    final uri = Uri.parse('$kApiBaseUrl/stats/my').replace(queryParameters: {
      'user_id': userId.toString(),
      'company_id': companyId.toString(),
      'year': year.toString(),
      'month': month.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? '통계 조회에 실패했습니다.');
    }

    return StatsModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

final statsServiceProvider = Provider<StatsService>((ref) => StatsService());
