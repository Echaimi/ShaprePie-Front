import 'package:flutter/material.dart';

class DepensePage extends StatelessWidget {
  const DepensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dépense Page'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Dépense Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
