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
      // appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                Navigator.pop(context); // Close RegisterScreen
              }
            },
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Create Your Account",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText:
                          emailController.text.isNotEmpty &&
                              !RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(emailController.text)
                          ? "Enter a valid email"
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: balanceController,
                    decoration: InputDecoration(
                      labelText: "Initial Balance (₹)",
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.app_registration),
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
                            const SnackBar(
                              content: Text("All fields are required"),
                            ),
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
                            const SnackBar(
                              content: Text("Email already registered"),
                            ),
                          );
                          return;
                        }

                        final userId = usersJson.length + 1;

                        final userMap = {
                          'userId': userId,
                          'name': name,
                          'email': email,
                          'password': password,
                          'currentBalance': balance,
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
                            currentBalance: balance,
                          ),
                        );
                      },
                      label: const Text(
                        "Register",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to login screen
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(fontSize: 16, color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
