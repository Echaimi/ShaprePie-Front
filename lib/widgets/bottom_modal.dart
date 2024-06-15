import 'package:flutter/material.dart';

class BottomModal extends StatelessWidget {
  final ScrollController scrollController;
  final Widget child;
  final double heightFactor;

  const BottomModal({
    super.key,
    required this.scrollController,
    required this.child,
    this.heightFactor = 0.9, // Par défaut, 90% de la hauteur de l'écran
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FractionallySizedBox(
      widthFactor: 1.0,
      heightFactor: heightFactor,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
