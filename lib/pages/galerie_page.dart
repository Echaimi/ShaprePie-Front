import 'package:flutter/material.dart';

class GaleriePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galerie Page'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Galerie Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
