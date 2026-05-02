class PolicyData {
  final int? mealLimit;
  final int? transportLimit;
  final String? allowedHours;
  final List<String> bannedItems;

  const PolicyData({
    this.mealLimit,
    this.transportLimit,
    this.allowedHours,
    this.bannedItems = const [],
  });

  factory PolicyData.fromJson(Map<String, dynamic> json) => PolicyData(
        mealLimit: json['meal_limit'] as int?,
        transportLimit: json['transport_limit'] as int?,
        allowedHours: json['allowed_hours'] as String?,
        bannedItems: (json['banned_items'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}

class RuleModel {
  final int id;
  final String ruleName;
  final PolicyData policyData;

  const RuleModel({
    required this.id,
    required this.ruleName,
    required this.policyData,
  });

  factory RuleModel.fromJson(Map<String, dynamic> json) => RuleModel(
        id: json['id'] as int,
        ruleName: json['rule_name'] as String? ?? '',
        policyData: json['policy_data'] != null
            ? PolicyData.fromJson(json['policy_data'] as Map<String, dynamic>)
            : const PolicyData(),
      );
}
