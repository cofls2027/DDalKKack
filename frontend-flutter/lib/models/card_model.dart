class CardModel {
  final int id;
  final String? userId;
  final String cardType;
  final String cardCompany;
  final String cardNumber;
  final String? cardDescription;
  final bool isActive;

  const CardModel({
    required this.id,
    this.userId,
    required this.cardType,
    required this.cardCompany,
    required this.cardNumber,
    this.cardDescription,
    required this.isActive,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        id: json['id'] as int,
        userId: json['user_id'] as String?,
        cardType: json['card_type'] as String? ?? '',
        cardCompany: json['card_company'] as String? ?? '',
        cardNumber: json['card_number'] as String? ?? '',
        cardDescription: json['card_description'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );
}
