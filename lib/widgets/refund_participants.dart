// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spaceshare/models/user_with_expenses.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class RefundParticipants extends StatefulWidget {
  final List<UserWithExpenses> users;
  final Function(UserWithExpenses) onUserSelected;
  final double totalAmount;
  final UserWithExpenses? selectedUser;

  const RefundParticipants({
    super.key,
    required this.users,
    required this.onUserSelected,
    required this.totalAmount,
    this.selectedUser,
  });

  @override
  _RefundParticipantsState createState() => _RefundParticipantsState();
}

class _RefundParticipantsState extends State<RefundParticipants> {
  late Map<String, bool> selectedParticipants;
  TextEditingController amountController = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    selectedParticipants = {
      for (var user in widget.users)
        user.username: widget.selectedUser?.username == user.username
    };
    amountController.text = widget.totalAmount.toStringAsFixed(2);
    _validateAmount();
  }

  void _validateAmount() {
    final double totalAmount = double.tryParse(amountController.text) ?? 0;

    setState(() {
      if (totalAmount < 0) {
        errorMessage = t(context)!.totalAmountError;
      } else {
        errorMessage = null;
      }
    });
  }

  void _onAmountChanged(String value) {
    _validateAmount();
  }

  void _onUserSelectionChanged(String username) {
    setState(() {
      selectedParticipants.updateAll((key, value) => key == username);
      _validateAmount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  t(context)!.participants,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  t(context)!.clickToEditAmount,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.secondary),
                ),
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.users.length,
                  itemBuilder: (context, index) {
                    final user = widget.users[index];
                    final isSelected = selectedParticipants[user.username]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == 0)
                          Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(right: 36.0),
                            child: Icon(
                              Icons.arrow_downward,
                              color: theme.colorScheme.secondary,
                              size: 16.0,
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.secondaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  _onUserSelectionChanged(user.username);
                                },
                                activeColor: Colors.green,
                                checkColor: Colors.white,
                              ),
                              Expanded(
                                child: Text(
                                  user.username,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              if (isSelected)
                                SizedBox(
                                  width: 70,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: amountController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(8),
                                            border: InputBorder.none,
                                            hintText: '0',
                                            hintStyle: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                    color: theme
                                                        .colorScheme.primary),
                                          ),
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                  color: theme
                                                      .colorScheme.primary),
                                          textAlign: TextAlign.center,
                                          onChanged: _onAmountChanged,
                                        ),
                                      ),
                                      Text(
                                        '€',
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
            ],
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
                onPressed: errorMessage == null &&
                        selectedParticipants.values.contains(true)
                    ? () {
                        final selectedUser = widget.users.firstWhere(
                          (user) => selectedParticipants[user.username]!,
                        );
                        widget.onUserSelected(selectedUser);
                        context.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withOpacity(
                      errorMessage == null &&
                              selectedParticipants.values.contains(true)
                          ? 1.0
                          : 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  t(context)!.selectParticipant,
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
