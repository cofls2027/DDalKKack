class UserModel {
  final String id;
  final String name;
  final String phone;
  final String position;
  final String role;
  final int companyId;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.position,
    required this.role,
    required this.companyId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        position: json['position'] as String? ?? '',
        role: json['role'] as String? ?? 'user',
        companyId: json['company_id'] as int? ?? 0,
      );
}
