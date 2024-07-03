import 'package:flutter/material.dart';
import 'package:nsm/screens/home_screen.dart';
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
  int selectedCategoryId = 1; // Default category ID

  Future<void> _createEvent(
      BuildContext context, Map<String, dynamic> eventData) async {
    final EventService eventService = EventService(ApiService());

    try {
      await eventService.createEvent(eventData);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  eventService: eventService,
                )),
      );
    } catch (e) {
      // Handle error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
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

              await _createEvent(context, eventData);
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
