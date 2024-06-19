import 'package:flutter/material.dart';
import 'event_form.dart';

class CreateEventModalContent extends StatelessWidget {
  const CreateEventModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController eventNameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController goalController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to start
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
            onSubmit: () {
              // Handle form submission
            },
          ),
        ],
      ),
    );
  }
}
