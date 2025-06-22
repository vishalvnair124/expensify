abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final int userId;
  final String name;

  AuthSuccess(this.userId, this.name);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}
