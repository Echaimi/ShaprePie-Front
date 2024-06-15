import 'dart:convert';
import '../models/event.dart';
import '../services/api_service.dart';

class EventService {
  final ApiService apiService;

  EventService(this.apiService);

  Future<List<Event>> getEvents() async {
    final response = await apiService.get('/events');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List events = data['data'];
      return events.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<Event> getEvent(int eventId) async {
    final response = await apiService.get('/events/$eventId');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return Event.fromJson(data);
    } else {
      throw Exception('Failed to load event');
    }
  }

  Future<Event> updateEvent(int eventId, Map<String, dynamic> data) async {
    final response = await apiService.patch('/events/$eventId', data);

    if (response.statusCode == 200) {
      Map<String, dynamic> updatedData = json.decode(response.body);
      return Event.fromJson(updatedData);
    } else {
      throw Exception('Failed to update event');
    }
  }

  Future<void> deleteEvent(int eventId) async {
    final response = await apiService.delete('/events/$eventId');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }
  }
}
