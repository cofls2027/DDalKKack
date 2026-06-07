class StatsModel {
  final int totalAmount;
  final Map<String, int> categoryStats;
  final Map<String, int> cardTypeStats;
  final Map<String, int> statusStats;

  const StatsModel({
    required this.totalAmount,
    required this.categoryStats,
    required this.cardTypeStats,
    required this.statusStats,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) => StatsModel(
        totalAmount: json['total_amount'] as int? ?? 0,
        categoryStats: _toIntMap(json['category_stats']),
        cardTypeStats: _toIntMap(json['card_type_stats']),
        statusStats: _toIntMap(json['status_stats']),
      );

  static Map<String, int> _toIntMap(dynamic raw) {
    if (raw == null) return {};
    return (raw as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toInt()),
    );
  }
}
