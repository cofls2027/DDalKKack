class Receipt {
  final int     id;
  final String  merchantName;
  final int     amount;
  final String  status;
  final String? rejectReason;
  final String  imageUrl;
  final String  createdAt;

  const Receipt({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.status,
    this.rejectReason,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    id:           json['id'],
    merchantName: json['merchant_name'] ?? '',
    amount:       json['amount']        ?? 0,
    status:       json['status']        ?? 'pending',
    rejectReason: json['reject_reason'],
    imageUrl:     json['image_url']     ?? '',
    createdAt:    json['created_at']    ?? '',
  );
}