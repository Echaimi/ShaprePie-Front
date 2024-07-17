import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 65,
      height: 65,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: theme.primaryColor,
        elevation: 4.0,
        highlightElevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(400),
        ),
        child: const Icon(
          Icons.add,
          size: 32.5,
          color: Colors.white,
        ),
      ),
    );
  }
}
