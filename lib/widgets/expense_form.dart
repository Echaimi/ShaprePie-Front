import 'package:flutter/material.dart';
import 'bottom_modal.dart';
import 'expense_concerned_by.dart';
import 'expense_reason.dart';
import '../models/tag.dart'; // Assurez-vous que le chemin est correct

class ExpenseForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const ExpenseForm({super.key, required this.onSubmit});

  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _concernController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Tag? _selectedTag;

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _concernController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final data = {
      'amount': _amountController.text,
      'purpose': _purposeController.text,
      'concern': _concernController.text,
      'date': _dateController.text,
      'tag': _selectedTag?.name,
    };
    widget.onSubmit(data);
    Navigator.pop(context);
  }

  void _openReasonExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomModal(
          scrollController: ScrollController(),
          child: ReasonExpense(
            onReasonSelected: (name, tag) {
              setState(() {
                _purposeController.text = name;
                _selectedTag = tag;
              });
            },
            initialReason: _purposeController.text,
            initialTag: _selectedTag,
          ),
        );
      },
    );
  }

  void _openExpenseConcernedByModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomModal(
          scrollController: ScrollController(),
          child: ExpenseConcernedBy(), // Appel de votre widget ExpenseFor
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        _buildTextField('Montant (00.00€)', _amountController, context),
        const SizedBox(height: 16.0),
        _buildTextField('Pour', _purposeController, context, onTap: _openReasonExpenseModal),
        const SizedBox(height: 16.0),
        _buildTextField('Concerne qui ?', _concernController, context, onTap: _openExpenseConcernedByModal),
        const SizedBox(height: 16.0),
        _buildTextField('Fait le (00/00/0000)', _dateController, context),
        const SizedBox(height: 16.0),
        SizedBox(
          width: 342,
          height: 56,
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: Text(
              'Ajouter la dépense',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, BuildContext context, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 342,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: AbsorbPointer(
          absorbing: onTap != null,
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
              labelStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              filled: true,
              fillColor: theme.colorScheme.primaryContainer,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}