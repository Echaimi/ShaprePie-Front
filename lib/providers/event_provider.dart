import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  final EventService eventService;
  List<Event> _events = [];
  bool _isLoading = false;

  EventProvider(this.eventService);

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _events = await eventService.getEvents();
    _isLoading = false;
    notifyListeners();
  }

  Event? getEventById(String eventId) {
    try {
      Event event = _events.firstWhere((event) => event.id == eventId);
      return event;
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchEvent(String eventId) async {
    Event event = await eventService.getEvent(eventId);
    _updateEventInList(event);
    notifyListeners();
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    Event event = await eventService.updateEvent(eventId, data);
    _updateEventInList(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await eventService.deleteEvent(eventId);
    _events.removeWhere((event) => event.id == eventId);
    notifyListeners();
  }

  void _updateEventInList(Event updatedEvent) {
    int index = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
    } else {
      _events.add(updatedEvent);
    }
  }
}
