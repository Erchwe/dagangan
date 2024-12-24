class UserModel {
  final String id;
  final String email;
  final String role;
  final DateTime createdAt;

  UserModel({required this.id, required this.email, required this.role, required this.createdAt});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
