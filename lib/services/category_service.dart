import 'dart:convert';
import 'package:spaceshare/models/category.dart';
import 'package:spaceshare/services/api_service.dart';

class CategoryService {
  final ApiService apiService;

  CategoryService(this.apiService);

  Future<List<Category>> getCategories({String? state}) async {
    final response = await apiService.get('/categories');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List categories = data['data'];
      return categories.map((category) => Category.fromJson(category)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Category> getCategory(int categoryId) async {
    final response = await apiService.get('/categories/$categoryId');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      final category = data['data'];
      return Category.fromJson(category);
    } else {
      throw Exception('Failed to load category');
    }
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    final response = await apiService.post('/categories', data);

    if (response.statusCode == 200) {
      Map<String, dynamic> createdData = json.decode(response.body);
      return Category.fromJson(createdData);
    } else {
      throw Exception('Failed to create category');
    }
  }

  Future<Category> updateCategory(
      int categoryId, Map<String, dynamic> data) async {
    final response = await apiService.patch('/categories/$categoryId', data);

    if (response.statusCode == 200) {
      Map<String, dynamic> updatedData = json.decode(response.body);
      return Category.fromJson(updatedData);
    } else {
      throw Exception('Failed to update category');
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    final response = await apiService.delete('/categories/$categoryId');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }
}
