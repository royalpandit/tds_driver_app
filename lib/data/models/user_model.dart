class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String userType;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['user_type'] ?? '',
    );
  }
}



