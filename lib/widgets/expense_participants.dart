// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spaceshare/models/participant.dart';
import 'package:spaceshare/models/user_with_expenses.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class ExpenseParticipants extends StatefulWidget {
  final List<UserWithExpenses> users;
  final Function(List<Participant>) onParticipantsSelected;
  final List<Participant> initialParticipants;
  final double totalAmount;

  const ExpenseParticipants({
    super.key,
    required this.users,
    required this.onParticipantsSelected,
    required this.initialParticipants,
    required this.totalAmount,
  });

  @override
  _ExpenseParticipantsState createState() => _ExpenseParticipantsState();
}

class _ExpenseParticipantsState extends State<ExpenseParticipants> {
  late Map<String, bool> selectedParticipants;
  late Map<String, TextEditingController> amountControllers;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialParticipants.isEmpty) {
      selectedParticipants = {
        for (var user in widget.users) user.username: true
      };
      amountControllers = {
        for (var user in widget.users)
          user.username: TextEditingController(
              text:
                  (widget.totalAmount / widget.users.length).toStringAsFixed(2))
      };
    } else {
      selectedParticipants = {
        for (var user in widget.users)
          user.username: widget.initialParticipants
              .any((p) => p.user.username == user.username)
      };
      amountControllers = {
        for (var user in widget.users)
          user.username: TextEditingController(
              text: widget.initialParticipants
                  .firstWhere((p) => p.user.username == user.username,
                      orElse: () => Participant(user: user, amount: 0))
                  .amount
                  .toString())
      };
    }
    _updateAmounts();
  }

  void _validateAmounts() {
    final double totalAmount = amountControllers.values
        .map((controller) => double.tryParse(controller.text) ?? 0)
        .fold(0, (sum, amount) => sum + amount);

    setState(() {
      if (totalAmount < 0) {
        errorMessage = t(context)!.totalAmountCannotBeNegative;
      } else {
        errorMessage = null;
      }
    });
  }

  void _onAmountChanged(String username, String value) {
    final double editedAmount = double.tryParse(value) ?? 0;
    final double totalAmount = widget.totalAmount;
    final int selectedCount =
        selectedParticipants.values.where((selected) => selected).length;

    double remainingAmount = totalAmount - editedAmount;

    if (selectedCount > 1) {
      final double dividedAmount =
          (remainingAmount / (selectedCount - 1) * 100).floor() / 100;

      for (var entry in amountControllers.entries) {
        if (selectedParticipants[entry.key]! && entry.key != username) {
          entry.value.text = dividedAmount.toStringAsFixed(2);
        }
      }

      double sumOfAmounts = editedAmount;
      for (var entry in amountControllers.entries) {
        if (selectedParticipants[entry.key]! && entry.key != username) {
          sumOfAmounts += double.tryParse(entry.value.text) ?? 0;
        }
      }
      if ((sumOfAmounts - totalAmount).abs() > 0.01) {
        final lastSelectedUser = selectedParticipants.entries
            .lastWhere((entry) => entry.value && entry.key != username)
            .key;
        final double lastUserAmount = totalAmount -
            sumOfAmounts +
            (double.tryParse(
                    amountControllers[lastSelectedUser]?.text ?? '0') ??
                0);
        amountControllers[lastSelectedUser]?.text =
            lastUserAmount.toStringAsFixed(2);
      }
    }

    _validateAmounts();
  }

  void _updateAmounts() {
    final double totalAmount = widget.totalAmount;
    final selectedUsersCount =
        selectedParticipants.values.where((selected) => selected).length;

    if (selectedUsersCount > 0 && totalAmount > 0) {
      final double dividedAmount =
          (totalAmount / selectedUsersCount * 100).floor() / 100;
      double sumOfAmounts = 0;

      for (var entry in amountControllers.entries) {
        if (selectedParticipants[entry.key]!) {
          sumOfAmounts += dividedAmount;
          entry.value.text = dividedAmount.toStringAsFixed(2);
        }
      }

      if (sumOfAmounts < totalAmount) {
        final lastSelectedUser =
            selectedParticipants.entries.lastWhere((entry) => entry.value).key;
        final double lastUserAmount =
            totalAmount - sumOfAmounts + dividedAmount;
        amountControllers[lastSelectedUser]?.text =
            lastUserAmount.toStringAsFixed(2);
      }
    } else {
      for (var entry in amountControllers.entries) {
        if (selectedParticipants[entry.key]!) {
          entry.value.text = '0';
        }
      }
    }

    _validateAmounts();
  }

  void _onUserSelectionChanged(String username, bool isSelected) {
    setState(() {
      selectedParticipants[username] = isSelected;

      if (isSelected) {
        _updateAmounts();
      } else {
        amountControllers[username]?.text = '0';
      }

      _updateAmounts();
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
                child: Text(t(context)!.participantsTitle,
                    style: theme.textTheme.titleSmall),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _selectAll,
                    child: Text(
                      t(context)!.selectAll,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _resetAmounts,
                    child: Text(
                      t(context)!.reset,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
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
                            color: selectedParticipants[user.username]!
                                ? theme.colorScheme.secondaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: selectedParticipants[user.username],
                                onChanged: (bool? value) {
                                  _onUserSelectionChanged(
                                      user.username, value!);
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
                              if (selectedParticipants[user.username]!)
                                SizedBox(
                                  width: 70,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              amountControllers[user.username],
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
                                          onChanged: (value) =>
                                              _onAmountChanged(
                                                  user.username, value),
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
                onPressed: errorMessage == null
                    ? () {
                        List<Participant> selectedUsers = widget.users
                            .where((user) =>
                                selectedParticipants[user.username] ?? false)
                            .map((user) => Participant(
                                  id: user.id,
                                  user: user,
                                  amount: double.tryParse(
                                          amountControllers[user.username]
                                                  ?.text ??
                                              '0') ??
                                      0,
                                ))
                            .toList();
                        widget.onParticipantsSelected(selectedUsers);
                        context.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary
                      .withOpacity(errorMessage == null ? 1.0 : 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  t(context)!.validateParticipants,
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

  void _selectAll() {
    setState(() {
      selectedParticipants.updateAll((key, value) => true);
      _updateAmounts();
    });
  }

  void _resetAmounts() {
    setState(() {
      for (var entry in amountControllers.entries) {
        if (selectedParticipants[entry.key]!) {
          entry.value.text = '0';
        }
      }
      _validateAmounts();
    });
  }
}
