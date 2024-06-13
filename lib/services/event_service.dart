import 'dart:convert';
import 'package:nsm/models/expense.dart';

import '../models/event.dart';
import '../services/api_service.dart';

class EventService {
  final ApiService apiService;

  EventService(this.apiService);

  Future<Event> getEvent(String eventId) async {
    final response = await apiService.get('/events/$eventId');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('Failed to load event');
    }
  }

  Future<List<Event>> getEvents() async {
    final response = await apiService.get('/events');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<Event> updateEvent(String eventId, Map<String, dynamic> data) async {
    final response = await apiService.patch('/events/$eventId', data);

    if (response.statusCode != 200) {
      throw Exception('Failed to update event');
    }

    return Event.fromJson(json.decode(response.body));
  }

  Future<List<Expense>> getExpenses(String eventId) async {
    final response = await apiService.get('/events/$eventId/expenses');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((expense) => Expense.fromJson(expense)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final response = await apiService.delete('/events/$eventId');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }
  }
}
