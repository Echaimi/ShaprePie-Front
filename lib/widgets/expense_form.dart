import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spaceshare/models/user_with_expenses.dart';
import 'package:spaceshare/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import 'bottom_modal.dart';
import 'expense_participants.dart';
import 'expense_payers.dart';
import 'expense_reason.dart';
import '../models/tag.dart';
import '../models/participant.dart';
import '../models/payer.dart';

class ExpenseForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final List<UserWithExpenses> users;
  final int eventId;
  final Expense? initialExpense;

  const ExpenseForm({
    super.key,
    required this.onSubmit,
    required this.users,
    required this.eventId,
    this.initialExpense,
  });

  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _participantController = TextEditingController();
  final TextEditingController _payerController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Tag? _selectedTag;
  List<Participant> _selectedParticipants = [];
  List<Payer> _selectedPayers = [];

  String? _amountError;
  String? _purposeError;
  String? _payerError;
  String? _participantError;
  String? _dateError;
  String? _tagError;

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _descriptionController.dispose();
    _participantController.dispose();
    _payerController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialExpense != null) {
      _amountController.text = widget.initialExpense!.amount.toString();
      _purposeController.text = widget.initialExpense!.name;
      _descriptionController.text = widget.initialExpense!.description;
      _dateController.text =
          DateFormat('dd/MM/yyyy').format(widget.initialExpense!.createdAt);
      _selectedTag = widget.initialExpense?.tag;
      _selectedParticipants = widget.initialExpense!.participants;
      _selectedPayers = widget.initialExpense!.payers;
    }
  }

  void _handleSubmit() {
    setState(() {
      _amountError =
          _amountController.text.isEmpty ? 'Le montant est obligatoire' : null;
      _purposeError = _purposeController.text.isEmpty
          ? 'Le nom de la dépense est obligatoire'
          : null;
      _payerError =
          _selectedPayers.isEmpty ? 'Au moins un payeur est obligatoire' : null;
      _participantError = _selectedParticipants.isEmpty
          ? 'Au moins un participant est obligatoire'
          : null;
      _dateError =
          _dateController.text.isEmpty ? 'La date est obligatoire' : null;
    });

    if (_amountError == null &&
        _purposeError == null &&
        _payerError == null &&
        _participantError == null &&
        _dateError == null &&
        _tagError == null) {
      final data = {
        'name': _purposeController.text,
        'description': _descriptionController.text,
        'tag': _selectedTag?.id,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'event': widget.eventId,
        'participants': _selectedParticipants.map((participant) {
          return {
            'id': participant.user.id,
            'amount': participant.amount,
          };
        }).toList(),
        'payers': _selectedPayers.map((payer) {
          return {
            'id': payer.user.id,
            'amount': payer.amount,
          };
        }).toList(),
      };
      widget.onSubmit(data);
      Navigator.pop(context);
      print(data);
    }
  }

  void _openReasonExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomModal(
          scrollController: ScrollController(),
          child: ReasonExpense(
            onReasonSelected: (name, description, tag, showTagList) {
              setState(() {
                _purposeController.text = name;
                _descriptionController.text = description;
                _selectedTag = tag;
              });
            },
            initialReason: _purposeController.text,
            initialDescription: _descriptionController.text,
            initialTag: _selectedTag,
          ),
        );
      },
    );
  }

  void _openExpenseParticipantsModal() async {
    String defaultAmount = _amountController.text;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomModal(
          scrollController: ScrollController(),
          child: ExpenseParticipants(
            users: widget.users,
            defaultAmount: defaultAmount,
            initialParticipants: _selectedParticipants,
            onParticipantsSelected: (selectedParticipants) {
              setState(() {
                _selectedParticipants = selectedParticipants;
                _participantController.text = selectedParticipants
                    .map((participant) => participant.user.username)
                    .join(', ');
              });
            },
          ),
        );
      },
    );
  }

  void _openExpensePayersModal() async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    String defaultAmount = _amountController.text;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomModal(
          scrollController: ScrollController(),
          child: ExpensePayers(
            users: widget.users,
            defaultAmount: defaultAmount,
            currentUser: currentUser,
            initialPayers: _selectedPayers,
            onPayersSelected: (selectedPayers) {
              setState(() {
                _selectedPayers = selectedPayers;
                _payerController.text = selectedPayers
                    .map((payer) => payer.user.username)
                    .join(', ');
              });
            },
          ),
        );
      },
    );
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildTextField('Montant (00.00€)', _amountController, context,
              keyboardType: TextInputType.number, errorText: _amountError),
          const SizedBox(height: 16.0),
          _buildTextField('Pour', _purposeController, context,
              onTap: _openReasonExpenseModal, errorText: _purposeError),
          const SizedBox(height: 16.0),
          _buildTextField('Payeurs', _payerController, context,
              onTap: _openExpensePayersModal, errorText: _payerError),
          const SizedBox(height: 16.0),
          _buildTextField('Participants', _participantController, context,
              onTap: _openExpenseParticipantsModal,
              errorText: _participantError),
          const SizedBox(height: 16.0),
          _buildTextField('Fait le (00/00/0000)', _dateController, context,
              onTap: () => _selectDate(context), errorText: _dateError),
          const SizedBox(height: 16.0),
          if (_tagError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _tagError!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
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
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, BuildContext context,
      {VoidCallback? onTap, TextInputType? keyboardType, String? errorText}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 342,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: AbsorbPointer(
          absorbing: onTap != null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: label,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelStyle:
                      theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                  filled: true,
                  fillColor: theme.colorScheme.secondaryContainer,
                  errorText: errorText,
                ),
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
