import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/category_controller.dart';
import '../../models/category.dart';

class CategoryDialogs {
  // Daftar warna pilihan
  static final List<Color> _colors = [
    const Color(0xFFFF0000), // Red
    const Color(0xFFFFC0CB), // Pink
    const Color(0xFF673AB7), // Deep Purple
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF2196F3), // Blue
    const Color(0xFF03A9F4), // Light Blue
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF009688), // Teal
    const Color(0xFF4CAF50), // Green
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFFCDDC39), // Lime
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFFFFC107), // Amber
    const Color(0xFFFF9800), // Orange
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF795548), // Brown
    const Color(0xFF9E9E9E), // Grey
    const Color(0xFF607D8B), // Blue Grey
  ];

  // Dialog Add
  static void showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    Color selectedColor = _colors.first; // Warna default

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Category Name'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Color'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _colors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color,
                                shape: selectedColor == color
                                    ? BoxShape.circle
                                    : BoxShape.rectangle,
                                border: selectedColor == color
                                    ? Border.all(color: Colors.black, width: 2)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  categoryController.addCategory(
                    nameController.text.trim(),
                    selectedColor,
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog Edit
  static void showEditDialog(BuildContext context, Category category) {
    final nameController = TextEditingController(text: category.name);
    final categoryController = Provider.of<CategoryController>(context, listen: false);
    Color selectedColor = category.color; // Warna dari data yang ada

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Category Name'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Color'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _colors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color,
                                shape: selectedColor == color
                                    ? BoxShape.circle
                                    : BoxShape.rectangle,
                                border: selectedColor == color
                                    ? Border.all(color: Colors.black, width: 2)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  categoryController.editCategory(
                    category.id,
                    nameController.text.trim(),
                    selectedColor,
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}