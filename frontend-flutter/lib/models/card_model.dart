class CardModel {
  final int id;
  final String cardType;
  final String cardCompany;
  final String cardNumber;
  final bool isActive;

  const CardModel({
    required this.id,
    required this.cardType,
    required this.cardCompany,
    required this.cardNumber,
    required this.isActive,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        id: json['id'] as int,
        cardType: json['card_type'] as String? ?? '',
        cardCompany: json['card_company'] as String? ?? '',
        cardNumber: json['card_number'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
      );
}
