class RuleModel {
  final int id;
  final String? categoryCode;
  final String? categoryName;
  final String? position;
  final int? maxAmount;
  final String? allowedTimeFrom;
  final String? allowedTimeTo;

  const RuleModel({
    required this.id,
    this.categoryCode,
    this.categoryName,
    this.position,
    this.maxAmount,
    this.allowedTimeFrom,
    this.allowedTimeTo,
  });

  factory RuleModel.fromJson(Map<String, dynamic> json) => RuleModel(
        id: json['id'] as int,
        categoryCode: json['category_code'] as String?,
        categoryName: json['category_name'] as String?,
        position: json['position'] as String?,
        maxAmount: json['max_amount'] as int?,
        allowedTimeFrom: json['allowed_time_from'] as String?,
        allowedTimeTo: json['allowed_time_to'] as String?,
      );
}
