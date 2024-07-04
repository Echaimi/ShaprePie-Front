import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../services/tags_service.dart';
import 'package:nsm/services/api_service.dart'; // Assurez-vous que le chemin est correct

class ReasonExpense extends StatefulWidget {
  final Function(String, Tag?) onReasonSelected;
  final String initialReason;
  final Tag? initialTag;

  const ReasonExpense({super.key, required this.onReasonSelected, required this.initialReason, this.initialTag});

  @override
  _ReasonExpenseState createState() => _ReasonExpenseState();
}

class _ReasonExpenseState extends State<ReasonExpense> {
  late final TextEditingController nameController;
  late final TagService _tagService;
  List<Tag> _tags = [];
  Tag? _selectedTag;
  bool _isLoading = true;
  bool _showTagList = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialReason);
    _selectedTag = widget.initialTag;
    _tagService = TagService(ApiService()); // Assurez-vous de fournir une instance d'ApiService
    _fetchTags();
  }

  void _fetchTags() async {
    try {
      final tags = await _tagService.getAllTags();
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Gérer les erreurs ici
      print('Erreur lors de la récupération des tags: $e');
    }
  }

  void _toggleTagSelection(Tag tag) {
    setState(() {
      _selectedTag = _selectedTag == tag ? null : tag;
    });
  }

  void _validateReason() {
    final name = nameController.text;
    widget.onReasonSelected(name, _selectedTag);
    Navigator.pop(context); // Close the modal
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'La raison ?',
              style: theme.textTheme.headline6?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            'C\'est un cadeau ? De quoi te retourner la tête ce soir ? Juste les courses ?',
            style: theme.textTheme.bodyText2?.copyWith(color: Colors.white),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 16.0),
          _buildTextField('Nom de la dépense', nameController, context),
          const SizedBox(height: 20.0),
          GestureDetector(
            onTap: () {
              setState(() {
                _showTagList = !_showTagList;
              });
            },
            child: Text(
              'Ajouter un tag',
              style: theme.textTheme.bodyText1?.copyWith(
                color: theme.colorScheme.secondary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          _isLoading
              ? const CircularProgressIndicator()
              : _showTagList
              ? _buildTagList()
              : Container(),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validateReason,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                'Valider la reason',
                style: theme.textTheme.bodyText1?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: theme.textTheme.bodyText2?.copyWith(color: Colors.white),
          filled: true,
          fillColor: theme.colorScheme.primaryContainer,
        ),
        style: theme.textTheme.bodyText2?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildTagList() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8.0,
      runSpacing: 12.0, // Increased spacing between lines
      children: _tags.map((tag) {
        final isSelected = _selectedTag == tag;
        return GestureDetector(
          onTap: () => _toggleTagSelection(tag),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              border: Border.all(color: theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              tag.name,
              style: theme.textTheme.bodyText2?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
