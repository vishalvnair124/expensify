import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

class HomeScreen extends StatelessWidget {
  final int userId;
  final String userName;

  const HomeScreen({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutUser());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text("User ID: $userId")),
    );
  }
}
