import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/api_service.dart';
import '../services/event_service.dart';

class EventForm extends StatefulWidget {
  final TextEditingController eventNameController;
  final TextEditingController descriptionController;
  final Future<void> Function() onSubmit;
  final Function(int) onCategorySelected;
  final String buttonText;

  const EventForm({
    super.key,
    required this.eventNameController,
    required this.descriptionController,
    required this.onSubmit,
    required this.buttonText,
    required this.onCategorySelected,
  });

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  late Future<List<Category>> _futureCategories;
  final CategoryService categoryService = CategoryService(ApiService());
  final EventService eventService = EventService(ApiService());
  int selectedCategoryId = 1; // Default category ID

  @override
  void initState() {
    super.initState();
    _futureCategories = categoryService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Choisissez une catégorie pour votre évènement',
            style: textTheme.bodySmall),
        const SizedBox(height: 8),
        FutureBuilder<List<Category>>(
          future: _futureCategories,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No categories available');
            } else {
              return Wrap(
                spacing: 8.0,
                children: snapshot.data!
                    .map((category) => _buildCategoryChip(context, category))
                    .toList(),
              );
            }
          },
        ),
        const SizedBox(height: 20.0),
        Text('En quel honneur ?', style: textTheme.bodySmall),
        const SizedBox(height: 8.0),
        TextField(
          controller: widget.eventNameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.1),
            labelText: 'Event name',
            labelStyle: textTheme.bodyMedium,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 1,
              ),
            ),
          ),
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: widget.descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.1),
            labelText: 'Description',
            labelStyle: textTheme.bodyMedium,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 1,
              ),
            ),
          ),
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 40.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary, // Set your button color here
            minimumSize: const Size(double.infinity, 50.0), // Full width button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () async {
            await widget.onSubmit(); // Call the custom submit function
          },
          child: Text(widget.buttonText,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, Category category) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ChoiceChip(
      label: Text(category.name,
          style: selectedCategoryId == category.id
              ? textTheme.bodySmall?.copyWith(color: colorScheme.surface)
              : textTheme.bodySmall),
      selected: selectedCategoryId == category.id,
      onSelected: (bool selected) {
        setState(() {
          selectedCategoryId = category.id;
          widget.onCategorySelected(selectedCategoryId);
        });
      },
      backgroundColor: colorScheme.primaryContainer,
      selectedColor: colorScheme.primary,
      shape: const StadiumBorder(),
    );
  }
}
