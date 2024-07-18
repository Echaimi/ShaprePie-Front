// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spaceshare/models/user.dart';
import 'package:spaceshare/providers/auth_provider.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import '../models/expense.dart';
import 'bottom_modal.dart';
import 'expense_participants.dart';
import 'expense_payers.dart';
import 'expense_reason.dart';
import '../models/tag.dart';
import '../models/participant.dart';
import '../models/payer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class ExpenseForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final Expense? initialExpense;

  const ExpenseForm({
    super.key,
    required this.onSubmit,
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
    _amountController.removeListener(_updateAmounts);
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
    final eventWebsocketProvider =
        Provider.of<EventWebsocketProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (widget.initialExpense != null) {
      _amountController.text = widget.initialExpense!.amount.toString();
      _purposeController.text = widget.initialExpense!.name;
      _descriptionController.text = widget.initialExpense!.description;
      _dateController.text =
          DateFormat('dd/MM/yyyy').format(widget.initialExpense!.date);
      _selectedTag = widget.initialExpense?.tag;
      _selectedParticipants = widget.initialExpense!.participants;
      _selectedPayers = widget.initialExpense!.payers;
    } else {
      _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _selectedParticipants = eventWebsocketProvider.users
          .map((user) => Participant(user: user, amount: 0))
          .toList();
      _selectedPayers = [Payer(user: authProvider.user!, amount: 0)];
    }

    _updateParticipantControllerText(authProvider.user!);
    _updatePayerControllerText(authProvider.user!);

    _amountController.addListener(_updateAmounts);
  }

  void _updateAmounts() {
    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    final participantsCount = _selectedParticipants.length;
    final payersCount = _selectedPayers.length;

    if (participantsCount > 0) {
      final dividedAmount = totalAmount / participantsCount;
      _selectedParticipants = _selectedParticipants.map((participant) {
        return Participant(user: participant.user, amount: dividedAmount);
      }).toList();
    }

    if (payersCount > 0) {
      final dividedAmount = totalAmount / payersCount;
      _selectedPayers = _selectedPayers.map((payer) {
        return Payer(user: payer.user, amount: dividedAmount);
      }).toList();
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _updateParticipantControllerText(authProvider.user!);
    _updatePayerControllerText(authProvider.user!);
  }

  void _updateParticipantControllerText(User currentUser) {
    if (_selectedParticipants.length == 1) {
      _participantController.text =
          _selectedParticipants.first.user.id == currentUser.id
              ? t(context)!.myself
              : _selectedParticipants.first.user.username;
    } else {
      _participantController.text =
          t(context)!.personsCount(_selectedParticipants.length);
    }
  }

  void _updatePayerControllerText(User currentUser) {
    if (_selectedPayers.length == 1) {
      _payerController.text = _selectedPayers.first.user.id == currentUser.id
          ? t(context)!.myself
          : _selectedPayers.first.user.username;
    } else {
      _payerController.text = t(context)!.personsCount(_selectedPayers.length);
    }
  }

  void _handleSubmit() {
    setState(() {
      _amountError =
          _amountController.text.isEmpty ? t(context)!.amountRequired : null;
      _purposeError =
          _purposeController.text.isEmpty ? t(context)!.purposeRequired : null;
      _payerError = _selectedPayers.isEmpty ? t(context)!.payerRequired : null;
      _participantError = _selectedParticipants.isEmpty
          ? t(context)!.participantRequired
          : null;
      _dateError =
          _dateController.text.isEmpty ? t(context)!.dateRequired : null;
    });

    if (_amountError == null &&
        _purposeError == null &&
        _payerError == null &&
        _participantError == null &&
        _dateError == null &&
        _tagError == null) {
      final eventWebsocketProvider =
          Provider.of<EventWebsocketProvider>(context, listen: false);

      final data = {
        'name': _purposeController.text,
        'description': _descriptionController.text,
        'tag': _selectedTag?.id,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'event': eventWebsocketProvider.event?.id,
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
        'date': DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
            .format(DateFormat('dd/MM/yyyy').parse(_dateController.text)),
      };
      widget.onSubmit(data);
      context.pop();
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
    final eventWebsocketProvider =
        Provider.of<EventWebsocketProvider>(context, listen: false);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomModal(
          scrollController: ScrollController(),
          child: ExpenseParticipants(
            users: eventWebsocketProvider.users,
            initialParticipants: _selectedParticipants,
            totalAmount: double.tryParse(_amountController.text) ?? 0.0,
            onParticipantsSelected: (selectedParticipants) {
              setState(() {
                _selectedParticipants = selectedParticipants;
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                _updateParticipantControllerText(authProvider.user!);
              });
            },
          ),
        );
      },
    );
  }

  void _openExpensePayersModal() async {
    final eventWebsocketProvider =
        Provider.of<EventWebsocketProvider>(context, listen: false);

    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomModal(
          scrollController: ScrollController(),
          child: ExpensePayers(
            users: eventWebsocketProvider.users,
            currentUser: currentUser,
            totalAmount: double.tryParse(_amountController.text) ?? 0.0,
            initialPayers: _selectedPayers,
            onPayersSelected: (selectedPayers) {
              setState(() {
                _selectedPayers = selectedPayers;
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                _updatePayerControllerText(authProvider.user!);
              });
            },
          ),
        );
      },
    );
  }

  void _selectDate(BuildContext context) async {
    DateTime? initialDate = widget.initialExpense?.date ?? DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildLabeledField(t(context)!.amountPlaceholderExpense,
                        _amountController, context,
                        keyboardType: TextInputType.number,
                        errorText: _amountError),
                    const SizedBox(height: 24.0),
                    _buildLabeledField(t(context)!.forPlaceholderExpense,
                        _purposeController, context,
                        errorText: _purposeError,
                        onTap: _openReasonExpenseModal),
                    const SizedBox(height: 24.0),
                    _buildLabeledField(t(context)!.payersPlaceholder,
                        _payerController, context,
                        errorText: _payerError, onTap: _openExpensePayersModal),
                    const SizedBox(height: 24.0),
                    _buildLabeledField(t(context)!.participantsPlaceholder,
                        _participantController, context,
                        errorText: _participantError,
                        onTap: _openExpenseParticipantsModal),
                    const SizedBox(height: 24.0),
                    _buildLabeledField(t(context)!.datePlaceholderExpense,
                        _dateController, context,
                        onTap: () => _selectDate(context),
                        errorText: _dateError),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 302,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    t(context)!.addExpenseButtonExpense,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(
      String label, TextEditingController controller, BuildContext context,
      {VoidCallback? onTap, TextInputType? keyboardType, String? errorText}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: AbsorbPointer(
              absorbing: onTap != null,
              child: TextField(
                textAlign: TextAlign.center,
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
                  errorText: errorText,
                ),
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
