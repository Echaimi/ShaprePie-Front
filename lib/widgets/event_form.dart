import 'package:flutter/material.dart';

class EventForm extends StatelessWidget {
  final TextEditingController eventNameController;
  final TextEditingController descriptionController;
  final TextEditingController goalController;
  final VoidCallback onSubmit;

  const EventForm({
    super.key,
    required this.eventNameController,
    required this.descriptionController,
    required this.goalController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Évènements', style: textTheme.titleSmall),
        const SizedBox(height: 5),
        Text('Choisissez une catégorie pour votre évènement',
            style: textTheme.bodySmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 5.0,
          runSpacing: 5.0,
          children: [
            _buildCategoryChip(context, 'Anniv'),
            _buildCategoryChip(context, 'Fête'),
            _buildCategoryChip(context, 'Voyage'),
            _buildCategoryChip(context, 'Vacances'),
            _buildCategoryChip(context, 'Autre'),
          ],
        ),
        const SizedBox(height: 20.0),
        TextField(
          controller: eventNameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.1),
            labelText: 'Event name',
            labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
          style: textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10.0),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.1),
            labelText: 'Description',
            labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
          style: textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10.0),
        TextField(
          controller: goalController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.1),
            labelText: 'Goal',
            labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
          style: textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // Set your button color here
            minimumSize: const Size(double.infinity, 50.0), // Full width button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: onSubmit,
          child: const Text('Créer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: colorScheme.primaryContainer,
    );
  }
}
