import 'package:flutter/material.dart';

class DepensePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dépense Page'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Dépense Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
