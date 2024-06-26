import 'package:flutter/material.dart';
import 'package:nsm/widgets/profile_avatar.dart';
import '../models/avatar.dart'; // Assurez-vous que le chemin d'importation est correct

class AvatarModalContent extends StatefulWidget {
  final List<Avatar> avatars;
  final ValueChanged<int?> onAvatarSelected;
  final String currentAvatarUrl; // Nouveau champ pour l'URL de l'avatar actuel

  const AvatarModalContent({
    Key? key,
    required this.avatars,
    required this.onAvatarSelected,
    required this.currentAvatarUrl, // Ajout du champ pour l'URL de l'avatar actuel
  }) : super(key: key);

  @override
  _AvatarModalContentState createState() => _AvatarModalContentState();
}

class _AvatarModalContentState extends State<AvatarModalContent> {
  int? selectedAvatarId;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final TextTheme textTheme = themeData.textTheme;
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Mon avatar",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 70, // Taille de l'avatar actuel
                      backgroundImage: NetworkImage(widget.currentAvatarUrl),
                    ),
                    const SizedBox(height: 16), // Espacement entre l'avatar et le texte
                    const Text(
                      "Choisis ton avatar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16), // Espacement entre le texte et la liste des avatars
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.avatars.map((avatar) {
                    bool isSelected = avatar.id == selectedAvatarId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatarId = avatar.id; // Sélectionnez l'avatar
                        });
                      },
                      child: ProfileAvatar(imageUrl: avatar.url, isSelected: isSelected)
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32), // Augmentez l'espace selon vos besoins
          ElevatedButton(
            onPressed: () {
              widget.onAvatarSelected(selectedAvatarId);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: colorScheme.secondary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: textTheme.bodyLarge,
            ),
            child: const Text('Valider l\'avatar'),
          ),
      ],
    );
  }
}