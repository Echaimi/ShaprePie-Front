import 'dart:convert';
import 'package:spaceshare/models/tag.dart';
import 'package:spaceshare/services/api_service.dart';

class TagService {
  final ApiService apiService;

  TagService(this.apiService);

  Future<List<Tag>> getTags({String? state}) async {
    final response = await apiService.get('/tags');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List tags = data['data'];
      return tags.map((tag) => Tag.fromJson(tag)).toList();
    } else {
      throw Exception('Failed to load tags');
    }
  }

  Future<Tag> getTag(int tagId) async {
    final response = await apiService.get('/tags/$tagId');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      final tag = data['data'];
      return Tag.fromJson(tag);
    } else {
      throw Exception('Failed to load tag');
    }
  }

  Future<Tag> createTag(Map<String, dynamic> data) async {
    final response = await apiService.post('/tags', data);

    if (response.statusCode == 200) {
      Map<String, dynamic> createdData = json.decode(response.body);
      return Tag.fromJson(createdData);
    } else {
      throw Exception('Failed to create tag');
    }
  }

  Future<Tag> updateTag(int tagId, Map<String, dynamic> data) async {
    final response = await apiService.patch('/tags/$tagId', data);

    if (response.statusCode == 200) {
      Map<String, dynamic> updatedData = json.decode(response.body);
      return Tag.fromJson(updatedData);
    } else {
      throw Exception('Failed to update tag');
    }
  }

  Future<void> deleteTag(int tagId) async {
    final response = await apiService.delete('/tags/$tagId');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete tag');
    }
  }
}
