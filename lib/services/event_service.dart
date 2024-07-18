import 'dart:convert';

import 'package:spaceshare/models/event.dart';
import 'package:spaceshare/models/expense.dart';
import 'package:spaceshare/models/user.dart';
import 'package:spaceshare/services/api_service.dart';

class EventService {
  final ApiService apiService;

  EventService(this.apiService);

  Future<List<Event>> getEvents() async {
    final response = await apiService.get('/events');
    print('GET /events response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List events = data['data'];
      return events.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<Event> createEvent(Map<String, dynamic> data) async {
    final response = await apiService.post('/events', data);
    print('POST /events response: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return Event.fromJson(responseData['data']);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Failed to create event: ${responseData['message']}');
    }
  }

  Future<Event> getEvent(int eventId) async {
    final response = await apiService.get('/events/$eventId');
    print('GET /events/$eventId response: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      final event = data['data'];
      return Event.fromJson(event);
    } else {
      throw Exception('Failed to load event');
    }
  }

  Future<List<User>> getEventUsers(int eventId) async {
    final response = await apiService.get('/events/$eventId/users');
    print('GET /events/$eventId/users response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List users = data['data'];
      return users.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load event users');
    }
  }

  Future<List<Expense>> getEventExpenses(int eventId) async {
    final response = await apiService.get('/events/$eventId/expenses');
    print('GET /events/$eventId/expenses response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List expenses = data['data'];
      return expenses.map((expense) => Expense.fromJson(expense)).toList();
    } else {
      throw Exception('Failed to load event expenses');
    }
  }

  Future<Event> updateEvent(int eventId, Map<String, dynamic> data) async {
    final response = await apiService.patch('/events/$eventId', data);
    print('PATCH /events/$eventId response: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> updatedData = json.decode(response.body);
      return Event.fromJson(updatedData);
    } else {
      throw Exception('Failed to update event');
    }
  }

  Future<void> deleteEvent(int eventId) async {
    final response = await apiService.delete('/events/$eventId');
    print('DELETE /events/$eventId response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }
  }

  Future<String> joinEvent(String code) async {
    final response = await apiService.post(
      '/events/join',
      {'code': code},
    );
    print('POST /events/join response: ${response.body}');

    if (response.statusCode == 200) {
      return response.body;
    } else {
      final responseData = json.decode(response.body);
      throw Exception(responseData['error']);
    }
  }

  Future<void> updateEventState(int eventId, String state) async {
    final response =
        await apiService.patch('/events/$eventId/state', {'state': state});
    print('PATCH /events/$eventId/state response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update event state');
    }
  }
}
