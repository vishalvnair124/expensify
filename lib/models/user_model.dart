class UserModel {
  final int userId;
  final String name;
  final String email;
  final String password;
  final double currentBalance; // ✅ new field

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.currentBalance, // ✅ add here too
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    'password': password,
    'currentBalance': currentBalance, // ✅ save to JSON
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json['userId'],
    name: json['name'],
    email: json['email'],
    password: json['password'],
    currentBalance: (json['currentBalance'] as num).toDouble(),
  );
}
