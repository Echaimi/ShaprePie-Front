// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/event_websocket_service.dart';
import 'event_form.dart';
import 'package:go_router/go_router.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

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
    context.pop();
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
                t(context)!.updateEventTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            EventForm(
              eventNameController: eventNameController,
              descriptionController: descriptionController,
              onSubmit: _updateEvent,
              buttonText: t(context)!.updateEventButton,
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
