import 'package:flutter/material.dart';
import '../services/event_websocket_service.dart';
import 'event_form.dart';

class UpdateEventModalContent extends StatefulWidget {
  final int eventId;
  final String initialEventName;
  final String initialDescription;
  final int initialCategoryId;
  final EventWebsocketProvider eventProvider;

  const UpdateEventModalContent({
    super.key,
    required this.eventId,
    required this.initialEventName,
    required this.initialDescription,
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
  late int selectedCategoryId;

  @override
  void initState() {
    super.initState();
    eventNameController = TextEditingController(text: widget.initialEventName);
    descriptionController =
        TextEditingController(text: widget.initialDescription);
    selectedCategoryId = widget.initialCategoryId;
  }

  Future<void> _updateEvent() async {
    final Map<String, dynamic> eventData = {
      'id': widget.eventId,
      'name': eventNameController.text,
      'description': descriptionController.text,
      'category': selectedCategoryId,
    };

    widget.eventProvider.updateEvent(eventData);
    Navigator.pop(context); // Close the modal after updating
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Modifier l\'évènement',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            EventForm(
              eventNameController: eventNameController,
              descriptionController: descriptionController,
              onSubmit: _updateEvent,
              buttonText: 'Modifier',
              onCategorySelected: (int categoryId) {
                setState(() {
                  selectedCategoryId = categoryId;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
