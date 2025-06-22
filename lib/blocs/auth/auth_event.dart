abstract class AuthEvent {}

class RegisterUser extends AuthEvent {
  final int userId;
  final String name;
  final String email;
  final String password;

  RegisterUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
  });
}

class LoginUser extends AuthEvent {
  final String email;
  final String password;

  LoginUser({required this.email, required this.password});
}

class CheckSession extends AuthEvent {}

class LogoutUser extends AuthEvent {}
