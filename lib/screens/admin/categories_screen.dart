import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Set the background color to white
      child: Scaffold(
        backgroundColor: Colors
            .transparent, // Prevent Scaffold from overriding the background color
        appBar: AppBar(
          title: const Text('Manage Categories'),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: Text('Categories management content here')),
      ),
    );
  }
}
