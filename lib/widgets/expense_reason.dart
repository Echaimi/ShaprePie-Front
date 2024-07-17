import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../services/tags_service.dart';
import 'package:spaceshare/services/api_service.dart'; // Assurez-vous que le chemin est correct

class ReasonExpense extends StatefulWidget {
  final Function(String, String, Tag?, bool) onReasonSelected;
  final String initialReason;
  final String initialDescription;
  final Tag? initialTag;

  const ReasonExpense({
    super.key,
    required this.onReasonSelected,
    required this.initialReason,
    required this.initialDescription,
    required this.initialTag,
  });

  @override
  _ReasonExpenseState createState() => _ReasonExpenseState();
}

class _ReasonExpenseState extends State<ReasonExpense> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TagService _tagService;
  List<Tag> _tags = [];
  Tag? _selectedTag;
  bool _isLoading = true;
  bool _showTagList = false;

  String? _nameError;
  String? _tagError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialReason);
    descriptionController =
        TextEditingController(text: widget.initialDescription);
    _selectedTag = widget.initialTag;
    _tagService = TagService(ApiService());
    _showTagList = widget.initialTag != null;
    _fetchTags();
  }

  void _toggleTagSelection(Tag tag) {
    setState(() {
      _selectedTag = _selectedTag == tag ? null : tag;
    });
  }

  void _toggleTagListVisibility() {
    setState(() {
      _showTagList = !_showTagList;
    });
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
      // Handle the error appropriately
    }
  }

  void _validateReason() {
    setState(() {
      _nameError = nameController.text.isEmpty
          ? 'Le nom de la dépense est obligatoire'
          : null;
      _tagError = _selectedTag == null
          ? 'La sélection d\'un tag est obligatoire'
          : null;
    });

    if (_nameError == null && _tagError == null) {
      widget.onReasonSelected(nameController.text, descriptionController.text,
          _selectedTag, _showTagList);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'La raison ?',
                style: theme.textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'C\'est un cadeau ? De quoi te retourner la tête ce soir ? Juste les courses ?',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24.0),
            _buildTextField('Nom de la dépense', nameController, context,
                errorText: _nameError),
            const SizedBox(height: 16.0),
            _buildDescriptionField(
                'Description', descriptionController, context),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: _toggleTagListVisibility,
              child: Text(
                'Ajouter un tag',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            _showTagList
                ? _isLoading
                    ? const CircularProgressIndicator()
                    : _buildTagList()
                : Container(),
            if (_tagError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _tagError!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _validateReason,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  'Valider la raison',
                  style:
                      theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, BuildContext context,
      {String? errorText}) {
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
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          filled: true,
          fillColor: theme.colorScheme.secondaryContainer,
          errorText: errorText,
        ),
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildDescriptionField(
      String label, TextEditingController controller, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        textInputAction: TextInputAction.done,
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          filled: true,
          fillColor: theme.colorScheme.secondaryContainer,
        ),
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildTagList() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8.0,
      runSpacing: 12.0,
      children: _tags.map((tag) {
        final isSelected = _selectedTag != null &&
            _selectedTag!.id == tag.id; // Comparer les ID des tags
        return GestureDetector(
          onTap: () => _toggleTagSelection(tag),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color:
                  isSelected ? theme.colorScheme.primary : Colors.transparent,
              border: Border.all(color: theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              tag.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
