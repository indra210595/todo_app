import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/category_controller.dart';
import './widgets/category_dialogs.dart'; // Akan kita bikin

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Consumer<CategoryController>(
        builder: (context, controller, child) {
          if (controller.categories.isEmpty) {
            return const Center(
              child: Text('No categories yet. Add one!'),
            );
          }

          return ListView.builder(
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.color,
                  ),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => CategoryDialogs.showEditDialog(context, category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.deleteCategory(category.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => CategoryDialogs.showAddDialog(context),
      ),
    );
  }
}