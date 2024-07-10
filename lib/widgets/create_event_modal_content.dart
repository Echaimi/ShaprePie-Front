import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nsm/models/event.dart';
import 'event_form.dart';
import '../services/event_service.dart';
import '../services/api_service.dart';

class CreateEventModalContent extends StatefulWidget {
  const CreateEventModalContent({super.key});

  @override
  _CreateEventModalContentState createState() =>
      _CreateEventModalContentState();
}

class _CreateEventModalContentState extends State<CreateEventModalContent> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  int selectedCategoryId = 1;

  Future<Event?> _createEvent(
      BuildContext context, Map<String, dynamic> eventData) async {
    final EventService eventService = EventService(ApiService());

    try {
      final event = await eventService.createEvent(eventData);
      return event;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
      return null; // Ensure this returns null on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              'L\'évènement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: Image.asset(
              'lib/assets/images/eventCreate.png',
              scale: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          EventForm(
            eventNameController: eventNameController,
            descriptionController: descriptionController,
            goalController: goalController,
            buttonText: 'Créer',
            onSubmit: () async {
              final Map<String, dynamic> eventData = {
                'name': eventNameController.text,
                'description': descriptionController.text,
                'category': selectedCategoryId,
                'goal': int.tryParse(goalController.text) ?? 0,
              };

              final event = await _createEvent(context, eventData);
              if (event != null && context.mounted) {
                context.go('/events/${event.id}');
              }
            },
            onCategorySelected: (int categoryId) {
              setState(() {
                selectedCategoryId = categoryId;
              });
            },
          ),
        ],
      ),
    );
  }
}
