import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';

class CategoryScreen extends StatefulWidget {
  final int userId;

  const CategoryScreen({super.key, required this.userId});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameController = TextEditingController();
  String _selectedType = 'Income';
  final Box _categoryBox = Hive.box('categories');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Categories")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Add New Category", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "Income", child: Text("Income")),
                DropdownMenuItem(value: "Expense", child: Text("Expense")),
              ],
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addCategory,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Category",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const Divider(height: 30),
            const Text("Your Categories", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _categoryBox.listenable(),
                builder: (context, box, _) {
                  final keys = box.keys.where((key) {
                    final item = box.get(key);
                    return item['userId'] == widget.userId;
                  }).toList();

                  return ListView.builder(
                    itemCount: keys.length,
                    itemBuilder: (context, index) {
                      final key = keys[index];
                      final category = box.get(key);

                      return ListTile(
                        leading: Icon(
                          category['type'] == "Income"
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: category['type'] == "Income"
                              ? Colors.green
                              : Colors.red,
                        ),

                        title: Text(category['name']),
                        subtitle: Text(category['type']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _editCategoryDialog(key, category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(key),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final category = CategoryModel(
      userId: widget.userId,
      name: name,
      type: _selectedType,
    );

    _categoryBox.add(category.toJson());
    _nameController.clear();
    setState(() {});
  }

  void _editCategoryDialog(dynamic key, Map category) {
    final editController = TextEditingController(text: category['name']);
    String selectedType = category['type'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "Income", child: Text("Income")),
                DropdownMenuItem(value: "Expense", child: Text("Expense")),
              ],
              onChanged: (value) => setState(() => selectedType = value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = CategoryModel(
                userId: widget.userId,
                name: editController.text.trim(),
                type: selectedType,
              );
              _categoryBox.put(key, updated.toJson());
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(dynamic key) {
    _categoryBox.delete(key);
    setState(() {});
  }
}
