import 'dart:convert';
import 'package:nsm/services/api_service.dart';

import '../models/tag.dart';

class TagService {
  final ApiService apiService;

  TagService(this.apiService);

  Future<List<Tag>> getAllTags() async {
    final response = await apiService.get('/tags');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((tag) => Tag.fromJson(tag)).toList();
    } else {
      throw Exception('Failed to load tags');
    }
  }
}
