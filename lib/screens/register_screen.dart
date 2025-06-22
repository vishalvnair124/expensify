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
    final balanceController = TextEditingController(); // ✅ new controller

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pop(context); // Close RegisterScreen
            }
          },
          child: ListView(
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
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(
                  labelText: "Initial Balance (₹)",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final name = nameController.text.trim();
                  final email = emailController.text.trim().toLowerCase();
                  final password = passwordController.text.trim();
                  final balanceText = balanceController.text.trim();

                  if (name.isEmpty ||
                      email.isEmpty ||
                      password.isEmpty ||
                      balanceText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("All fields are required")),
                    );
                    return;
                  }

                  final balance = double.tryParse(balanceText);
                  if (balance == null || balance < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Balance must be a number ≥ 0"),
                      ),
                    );
                    return;
                  }

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
                    'currentBalance': balance, // ✅ store balance
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
                      currentBalance: balance, // ✅ pass to event
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
