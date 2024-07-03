import 'package:flutter/material.dart';
import '../services/event_websocket_service.dart';
import 'event_form.dart';

class UpdateEventModalContent extends StatefulWidget {
  final int eventId;
  final String initialEventName;
  final String initialDescription;
  final int initialGoal;
  final int initialCategoryId;
  final EventWebsocketProvider eventProvider; // Add the provider as a parameter

  const UpdateEventModalContent({
    super.key,
    required this.eventId,
    required this.initialEventName,
    required this.initialDescription,
    required this.initialGoal,
    required this.initialCategoryId,
    required this.eventProvider,
  });

  @override
  _UpdateEventModalContentState createState() =>
      _UpdateEventModalContentState();
}

class _UpdateEventModalContentState extends State<UpdateEventModalContent> {
  late TextEditingController eventNameController;
  late TextEditingController descriptionController;
  late TextEditingController goalController;
  late int selectedCategoryId;

  @override
  void initState() {
    super.initState();
    eventNameController = TextEditingController(text: widget.initialEventName);
    descriptionController =
        TextEditingController(text: widget.initialDescription);
    goalController = TextEditingController(text: widget.initialGoal.toString());
    selectedCategoryId = widget.initialCategoryId;
  }

  Future<void> _updateEvent() async {
    final Map<String, dynamic> eventData = {
      'id': widget.eventId,
      'name': eventNameController.text,
      'description': descriptionController.text,
      'category': selectedCategoryId,
      'goal': int.tryParse(goalController.text) ?? 0,
    };

    widget.eventProvider.updateEvent(eventData);
    Navigator.pop(context); // Close the modal after updating
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
              'Modifier l\'évènement',
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
            onSubmit: _updateEvent, // Call the update event method
            buttonText: 'Modifier',
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
