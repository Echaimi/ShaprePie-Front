import 'dart:convert';
import '../models/category.dart';
import '../services/api_service.dart';


class CategoryService {
  final ApiService apiService;

  CategoryService(this.apiService);

  Future<List<Category>> getCategories() async {
    final response = await apiService.get('/categories');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List categories = data['data'];
      return categories.map((dynamic item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}