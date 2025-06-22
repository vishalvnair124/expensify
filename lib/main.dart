import 'package:expensify/blocs/auth/auth_state.dart';
import 'package:expensify/blocs/transaction/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive boxes (only transactions & categories)
  await Hive.openBox('transactions');
  await Hive.openBox('categories');

  runApp(const ExpensifyApp());
}

class ExpensifyApp extends StatelessWidget {
  const ExpensifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(CheckSession())),
        BlocProvider(create: (_) => TransactionBloc()), // <-- Add this
      ],
      child: MaterialApp(
        title: 'Expensify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return HomeScreen(userId: state.userId, userName: state.name);
        } else if (state is AuthFailure) {
          return const LoginScreen(); // login failed
        } else if (state is AuthInitial) {
          return const LoginScreen(); // no user yet
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const LoginScreen(); // fallback
        }
      },
    );
  }
}
