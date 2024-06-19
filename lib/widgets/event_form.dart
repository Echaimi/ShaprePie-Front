import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/api_service.dart';
import '../services/event_service.dart';

class EventForm extends StatefulWidget {
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

  Future<void> _createEvent() async {
    final Map<String, dynamic> eventData = {
      'name': widget.eventNameController.text,
      'description': widget.descriptionController.text,
      'category': selectedCategoryId, // Use selected category ID
      'goal': int.tryParse(widget.goalController.text) ?? 0, // Parse goal as an integer
    };

    try {
      await eventService.createEvent(eventData);
      widget.onSubmit(); // Call the onSubmit callback
    } catch (e) {
      // Handle error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

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
                spacing: 10.0,
                runSpacing: 10.0,
                children: snapshot.data!
                    .map((category) =>
                        _buildCategoryChip(context, category))
                    .toList(),
              );
            }
          },
        ),
        const SizedBox(height: 20.0),
        Text('En quel honneur ?', style: textTheme.bodySmall),
        const SizedBox(height: 10.0),
        TextField(
          controller: widget.eventNameController,
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
          controller: widget.descriptionController,
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
          controller: widget.goalController,
          keyboardType: TextInputType.number, // Numeric keyboard
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
          onPressed: _createEvent, // Call the create event method
          child: const Text('Créer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, Category category) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(
        category.name,
        style: const TextStyle(color: Colors.white),
      ),
      selected: selectedCategoryId == category.id,
      onSelected: (bool selected) {
        setState(() {
          selectedCategoryId = category.id; // Update selected category ID
        });
      },
      backgroundColor: colorScheme.primaryContainer,
      selectedColor: colorScheme.secondary,
      shape: const StadiumBorder(),
    );
  }
}
