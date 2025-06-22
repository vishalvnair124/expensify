abstract class AuthEvent {}

class RegisterUser extends AuthEvent {
  final int userId;
  final String name;
  final String email;
  final String password;
  final double currentBalance; // ✅ new field

  RegisterUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.currentBalance, // ✅ required parameter
  });
}

class LoginUser extends AuthEvent {
  final String email;
  final String password;

  LoginUser({required this.email, required this.password});
}

class CheckSession extends AuthEvent {}

class LogoutUser extends AuthEvent {}
