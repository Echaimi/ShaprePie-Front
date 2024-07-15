import 'package:flutter/material.dart';
import 'package:spaceshare/models/user.dart';
import 'package:spaceshare/models/user_with_expenses.dart';
import '../models/payer.dart';

class ExpensePayers extends StatefulWidget {
  final List<UserWithExpenses> users;
  final String defaultAmount;
  final User? currentUser;
  final Function(List<Payer>) onPayersSelected;
  final List<Payer> initialPayers;

  ExpensePayers({
    required this.users,
    required this.defaultAmount,
    this.currentUser,
    required this.onPayersSelected,
    required this.initialPayers,
  });

  @override
  _ExpensePayersState createState() => _ExpensePayersState();
}

class _ExpensePayersState extends State<ExpensePayers> {
  late List<UserWithExpenses> sortedUsers;
  late Map<String, bool> selectedPayers;
  late Map<String, TextEditingController> amountControllers;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    sortedUsers = List.from(widget.users);
    if (widget.currentUser != null) {
      sortedUsers.sort((a, b) {
        if (a.id == widget.currentUser!.id) {
          return -1;
        } else if (b.id == widget.currentUser!.id) {
          return 1;
        }
        return 0;
      });
    }

    selectedPayers = {for (var user in sortedUsers) user.username: false};
    amountControllers = {for (var user in sortedUsers) user.username: TextEditingController(text: '0')};

    for (var payer in widget.initialPayers) {
      selectedPayers[payer.user.username] = true;
      amountControllers[payer.user.username]?.text = payer.amount.toString();
    }

    if (widget.currentUser != null && sortedUsers.any((user) => user.id == widget.currentUser!.id)) {
      selectedPayers[widget.currentUser!.username] = true;
      amountControllers[widget.currentUser!.username]?.text = widget.defaultAmount;
    }

    _updateAmounts();
  }

  void _validateAmounts() {
    final double totalAmount = amountControllers.values
        .map((controller) => double.tryParse(controller.text) ?? 0)
        .fold(0, (sum, amount) => sum + amount);

    final double defaultAmount = double.tryParse(widget.defaultAmount) ?? 0;
    const double tolerance = 0.01; // Tolerance of 1 cent

    setState(() {
      if ((totalAmount - defaultAmount).abs() <= tolerance) {
        errorMessage = null;
      } else if (totalAmount > defaultAmount) {
        errorMessage = 'Le montant total dépasse le montant par défaut.';
      } else {
        errorMessage = 'Le montant total est inférieur au montant par défaut.';
      }
    });
  }

  void _onAmountChanged(String username, String value) {
    final double editedAmount = double.tryParse(value) ?? 0;
    final double totalAmount = double.tryParse(widget.defaultAmount) ?? 0;
    final int selectedCount = selectedPayers.values.where((selected) => selected).length;

    if (editedAmount > totalAmount) {
      setState(() {
        errorMessage = 'Le montant saisi dépasse le montant total disponible.';
      });
      return;
    }

    double remainingAmount = totalAmount - editedAmount;

    if (selectedCount > 1) {
      final double dividedAmount = (remainingAmount / (selectedCount - 1) * 100).floor() / 100;

      for (var entry in amountControllers.entries) {
        if (selectedPayers[entry.key]! && entry.key != username) {
          entry.value.text = dividedAmount.toStringAsFixed(2);
        }
      }

      double sumOfAmounts = editedAmount;
      for (var entry in amountControllers.entries) {
        if (selectedPayers[entry.key]! && entry.key != username) {
          sumOfAmounts += double.tryParse(entry.value.text) ?? 0;
        }
      }
      if ((sumOfAmounts - totalAmount).abs() > 0.01) {
        final lastSelectedUser = selectedPayers.entries.lastWhere((entry) => entry.value && entry.key != username).key;
        final double lastUserAmount = totalAmount - sumOfAmounts + (double.tryParse(amountControllers[lastSelectedUser]?.text ?? '0') ?? 0);
        amountControllers[lastSelectedUser]?.text = lastUserAmount.toStringAsFixed(2);
      }
    }

    _validateAmounts();
  }

  void _updateAmounts() {
    final selectedUsersCount = selectedPayers.values.where((selected) => selected).length;
    if (selectedUsersCount > 0) {
      final double totalAmount = double.tryParse(widget.defaultAmount) ?? 0;
      final double dividedAmount = (totalAmount / selectedUsersCount * 100).floor() / 100;
      double sumOfAmounts = 0;

      for (var entry in amountControllers.entries) {
        if (selectedPayers[entry.key]!) {
          sumOfAmounts += dividedAmount;
          entry.value.text = dividedAmount.toStringAsFixed(2);
        }
      }

      if (sumOfAmounts < totalAmount) {
        final lastSelectedUser = selectedPayers.entries.lastWhere((entry) => entry.value).key;
        final double lastUserAmount = totalAmount - sumOfAmounts + dividedAmount;
        amountControllers[lastSelectedUser]?.text = lastUserAmount.toStringAsFixed(2);
      }
    }

    _validateAmounts();
  }

  void _onUserSelectionChanged(String username, bool isSelected) {
    setState(() {
      selectedPayers[username] = isSelected;

      if (isSelected) {
        _updateAmounts();
      } else {
        amountControllers[username]?.text = '0';
      }

      _updateAmounts();
      _validateAmounts();
    });
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
              'Qui a Khalass ?',
              style: theme.textTheme.titleSmall!.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            "Au cœur de l'arène financière, les preux payeurs s'élancent. Ici, chaque geste de générosité est un éclat de noblesse.",
            style: theme.textTheme.bodyMedium!.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _selectAll,
                child: Text(
                  'Tout sélectionner',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _resetAmounts,
                child: Text(
                  'Réinitialiser',
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
              'Cliquez pour modifier le montant',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
            ),
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: ListView.builder(
              itemCount: sortedUsers.length,
              itemBuilder: (context, index) {
                final user = sortedUsers[index];
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
                        color: selectedPayers[user.username]!
                            ? theme.colorScheme.secondaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: selectedPayers[user.username],
                            onChanged: (bool? value) {
                              _onUserSelectionChanged(user.username, value!);
                            },
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                          ),
                          Expanded(
                            child: Text(
                              user.username,
                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                            ),
                          ),
                          if (selectedPayers[user.username]!)
                            SizedBox(
                              width: 70,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: amountControllers[user.username],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(8),
                                        border: InputBorder.none,
                                        hintText: '0',
                                        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary),
                                      ),
                                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary),
                                      textAlign: TextAlign.center,
                                      onChanged: (value) => _onAmountChanged(user.username, value),
                                    ),
                                  ),
                                  Text(
                                    '€',
                                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary),
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
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: errorMessage == null
                  ? () {
                List<Payer> selectedUsers = sortedUsers
                    .where((user) => selectedPayers[user.username] ?? false)
                    .map((user) => Payer(
                  id: user.id,
                  user: user,
                  amount: double.tryParse(amountControllers[user.username]?.text ?? '0') ?? 0,
                ))
                    .toList();
                widget.onPayersSelected(selectedUsers);
                Navigator.pop(context);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withOpacity(errorMessage == null ? 1.0 : 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                'Valider les payeurs',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAll() {
    setState(() {
      selectedPayers.updateAll((key, value) => true);
      _updateAmounts();
    });
  }

  void _resetAmounts() {
    setState(() {
      for (var entry in amountControllers.entries) {
        if (selectedPayers[entry.key]!) {
          entry.value.text = '0';
        }
      }
      _validateAmounts();
    });
  }
}