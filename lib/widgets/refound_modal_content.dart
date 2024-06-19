import 'package:flutter/material.dart';

class RefundModalContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Center(
        child: Text(
          'Coming Soon',
          style: theme.textTheme.titleMedium!.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
