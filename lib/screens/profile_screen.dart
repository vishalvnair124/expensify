import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('user');
    if (currentUser != null) {
      final userMap = jsonDecode(currentUser);
      setState(() {
        email = userMap['email'];
        _nameController.text = userMap['name'];
        _passwordController.text = userMap['password'];
      });
    }
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = prefs.getStringList('users') ?? [];

    final updatedUsers = usersList.map((userJson) {
      final user = jsonDecode(userJson);
      if (user['userId'] == widget.userId) {
        user['name'] = _nameController.text.trim();
        user['password'] = _passwordController.text.trim();
        return jsonEncode(user);
      }
      return userJson;
    }).toList();

    await prefs.setStringList('users', updatedUsers);

    final updatedUser = updatedUsers.firstWhere(
      (u) => jsonDecode(u)['userId'] == widget.userId,
    );
    await prefs.setString('user', updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 30),
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.indigo.shade100,
            child: const Icon(Icons.person, size: 50, color: Colors.indigo),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: email),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                    backgroundColor: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
