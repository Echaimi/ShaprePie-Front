import 'package:flutter/material.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Set the background color to white
      child: Scaffold(
        backgroundColor: Colors
            .transparent, // Prevent Scaffold from overriding the background color
        appBar: AppBar(
          title: const Text('Manage Tags'),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: Text('Tags management content here')),
      ),
    );
  }
}
