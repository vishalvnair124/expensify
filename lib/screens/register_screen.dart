import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pop(context); // Close RegisterScreen, go back to Home
            }
          },
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final name = nameController.text.trim();
                  final email = emailController.text.trim().toLowerCase();
                  final password = passwordController.text.trim();

                  final usersJson = prefs.getStringList('users') ?? [];

                  final exists = usersJson.any((u) {
                    final user = jsonDecode(u);
                    return user['email'] == email;
                  });

                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Email already registered")),
                    );
                    return;
                  }

                  final userId = usersJson.length + 1;

                  final userMap = {
                    'userId': userId,
                    'name': name,
                    'email': email,
                    'password': password,
                  };

                  usersJson.add(jsonEncode(userMap));
                  await prefs.setStringList('users', usersJson);
                  await prefs.setString('user', jsonEncode(userMap));

                  context.read<AuthBloc>().add(
                    RegisterUser(
                      userId: userId,
                      name: name,
                      email: email,
                      password: password,
                    ),
                  );
                },
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
