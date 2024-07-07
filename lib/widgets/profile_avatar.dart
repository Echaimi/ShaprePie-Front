import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isSelected;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    return Container(
      width: 30.0,
      height: 30.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }
}
