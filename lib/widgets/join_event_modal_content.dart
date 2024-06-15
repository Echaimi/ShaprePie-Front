import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class JoinEventModalContent extends StatelessWidget {
  const JoinEventModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Fermer',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Rejoindre un évènement',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Lottie.asset(
              'lib/assets/animations/joinEvent.json',
              height: 300,
            ),
          ),
          const Center(
            child: Text(
              'Le créateur de l\'évènement t\'as envoyé un code pour rejoindre la partie ! Rien reçu ? Contacte le directement',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 35),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black.withOpacity(0.1),
              labelText: 'Code de l\'évènement',
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Rejoindre',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
