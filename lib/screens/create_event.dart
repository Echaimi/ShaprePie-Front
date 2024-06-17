import 'package:flutter/material.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un évènement'),
      ),
      body: const Center(
        child: Text(
          'New Event Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
