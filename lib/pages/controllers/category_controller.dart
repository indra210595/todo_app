import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/category.dart';

class CategoryController extends ChangeNotifier {
  List<Category> categories = [];

  CategoryController() {
    loadCategories();
  }

  // Load kategori
  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('categories');

    if (stored != null) {
      final List decoded = jsonDecode(stored);
      categories = decoded.map((e) => Category.fromMap(e)).toList();
      notifyListeners();
    }
  }

  // Simpan kategori
  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('categories', jsonEncode(categories.map((e) => e.toMap()).toList()));
  }

  // Tambah kategori
  void addCategory(String name, Color color) {
    categories.add(Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
    ));
    saveCategories();
    notifyListeners();
  }

  // Edit kategori
  void editCategory(String id, String name, Color color) {
    final index = categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      categories[index].name = name;
      categories[index].color = color;
      saveCategories();
      notifyListeners();
    }
  }

  // Hapus kategori
  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    saveCategories();
    notifyListeners();
  }
}