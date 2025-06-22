import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<RegisterUser>(_onRegisterUser);
    on<LoginUser>(_onLoginUser);
    on<CheckSession>(_onCheckSession);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final prefs = await SharedPreferences.getInstance();
    final userMap = {
      'userId': event.userId,
      'name': event.name,
      'email': event.email,
      'password': event.password,
    };
    await prefs.setString('user', jsonEncode(userMap));
    emit(AuthSuccess(event.userId, event.name));
  }

  Future<void> _onLoginUser(LoginUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final prefs = await SharedPreferences.getInstance();
    final usersList = prefs.getStringList('users');

    if (usersList != null && usersList.isNotEmpty) {
      for (final userJson in usersList) {
        final user = jsonDecode(userJson);
        if (user['email'] == event.email &&
            user['password'] == event.password) {
          // ✅ Save session
          await prefs.setString('user', jsonEncode(user));
          emit(AuthSuccess(user['userId'], user['name']));
          return;
        }
      }
    }

    emit(AuthFailure("Invalid email or password"));
  }

  Future<void> _onCheckSession(
    CheckSession event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      final userMap = jsonDecode(userData);
      emit(AuthSuccess(userMap['userId'], userMap['name']));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onLogoutUser(LogoutUser event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    emit(AuthInitial());
  }
}
