import 'package:expensify/blocs/transaction/transaction_bloc.dart';
import 'package:expensify/screens/add_transaction_screen.dart';
import 'package:expensify/screens/category_screen.dart';
import 'package:expensify/screens/dashboard_screen.dart';
import 'package:expensify/screens/profile_screen.dart';
import 'package:expensify/screens/transaction_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const HomeScreen({super.key, required this.userId, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.userName}"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutUser());
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildPage(),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 2
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'category',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryScreen(userId: widget.userId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.category),
                  label: const Text("Add Category"),
                ),

                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<TransactionBloc>(),
                          child: AddTransactionScreen(userId: widget.userId),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.attach_money),
                  label: const Text("Add Transaction"),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Transactions",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(userId: widget.userId);
      case 1:
        return TransactionHistoryScreen(userId: widget.userId);
      case 2:
        return ProfileScreen(userId: widget.userId);
      default:
        return const SizedBox.shrink();
    }
  }
}
