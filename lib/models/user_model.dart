//user_model.dart

class UserModel {
  final int userId;
  final String name;
  final String email;
  final String password;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    'password': password,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json['userId'],
    name: json['name'],
    email: json['email'],
    password: json['password'],
  );
}
