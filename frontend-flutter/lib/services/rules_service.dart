import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/rule_model.dart';

class RulesService {
  Future<List<RuleModel>> fetchRules(int companyId) async {
    final uri = Uri.parse('$kApiBaseUrl/rules').replace(queryParameters: {
      'company_id': companyId.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? '규정 조회에 실패했습니다.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => RuleModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final rulesServiceProvider = Provider<RulesService>((ref) => RulesService());
