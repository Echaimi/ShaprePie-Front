import 'package:flutter/material.dart';

class GaleriePage extends StatelessWidget {
  const GaleriePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie Page'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Galerie Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
