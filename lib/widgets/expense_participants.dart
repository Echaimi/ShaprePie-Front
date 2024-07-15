import 'package:flutter/material.dart';
import 'package:spaceshare/models/user_with_expenses.dart';
import '../models/participant.dart';

class ExpenseParticipants extends StatefulWidget {
  final List<UserWithExpenses> users;
  final String defaultAmount;
  final Function(List<Participant>) onParticipantsSelected;
  final List<Participant> initialParticipants;

  ExpenseParticipants({
    required this.users,
    required this.defaultAmount,
    required this.onParticipantsSelected,
    required this.initialParticipants,
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
    selectedParticipants = {for (var user in widget.users) user.username: true};
    amountControllers = {for (var user in widget.users) user.username: TextEditingController(text: '0')};

    for (var participant in widget.initialParticipants) {
      selectedParticipants[participant.user.username] = true;
      amountControllers[participant.user.username]?.text = participant.amount.toString();
    }

    _updateAmounts();
  }

  void _validateAmounts() {
    final double totalAmount = amountControllers.values
        .map((controller) => double.tryParse(controller.text) ?? 0)
        .fold(0, (sum, amount) => sum + amount);

    final double defaultAmount = double.tryParse(widget.defaultAmount) ?? 0;
    final double tolerance = 0.01; // Tolérance de 1 centime

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
    final int selectedCount = selectedParticipants.values.where((selected) => selected).length;

    // Valider si le montant édité dépasse le montant total
    if (editedAmount > totalAmount) {
      setState(() {
        errorMessage = 'Le montant saisi dépasse le montant total disponible.';
      });
      return;
    }

    // Calculer le montant restant après avoir modifié le montant de l'utilisateur actuel
    double remainingAmount = totalAmount - editedAmount;

    // Répartir le montant restant entre les autres utilisateurs sélectionnés
    if (selectedCount > 1) {
      final double dividedAmount = (remainingAmount / (selectedCount - 1) * 100).floor() / 100;

      for (var entry in amountControllers.entries) {
        if (selectedParticipants[entry.key]! && entry.key != username) {
          entry.value.text = dividedAmount.toStringAsFixed(2);
        }
      }

      // Ajuster le montant du dernier utilisateur pour compenser les erreurs d'arrondi
      double sumOfAmounts = editedAmount;
      for (var entry in amountControllers.entries) {
        if (selectedParticipants[entry.key]! && entry.key != username) {
          sumOfAmounts += double.tryParse(entry.value.text) ?? 0;
        }
      }
      if ((sumOfAmounts - totalAmount).abs() > 0.01) {
        final lastSelectedUser = selectedParticipants.entries.lastWhere((entry) => entry.value && entry.key != username).key;
        final double lastUserAmount = totalAmount - sumOfAmounts + (double.tryParse(amountControllers[lastSelectedUser]?.text ?? '0') ?? 0);
        amountControllers[lastSelectedUser]?.text = lastUserAmount.toStringAsFixed(2);
      }
    }

    // Valider les montants après la modification
    _validateAmounts();
  }

  void _updateAmounts() {
    final selectedUsersCount = selectedParticipants.values.where((selected) => selected).length;
    if (selectedUsersCount > 0) {
      final double totalAmount = double.tryParse(widget.defaultAmount) ?? 0;
      final double dividedAmount = (totalAmount / selectedUsersCount * 100).floor() / 100;
      double sumOfAmounts = 0;

      for (var entry in amountControllers.entries) {
        if (selectedParticipants[entry.key]!) {
          sumOfAmounts += dividedAmount;
          entry.value.text = dividedAmount.toStringAsFixed(2);
        }
      }

      // Si la somme des montants est inférieure au montant total, ajustez le montant du dernier utilisateur sélectionné
      if (sumOfAmounts < totalAmount) {
        final lastSelectedUser = selectedParticipants.entries.lastWhere((entry) => entry.value).key;
        final double lastUserAmount = totalAmount - sumOfAmounts + dividedAmount;
        amountControllers[lastSelectedUser]?.text = lastUserAmount.toStringAsFixed(2);
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

      _updateAmounts();  // Recalculate amounts when selection changes
      _validateAmounts();  // Validate amounts after recalculation
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
              'Sélectionner les participants',
              style: theme.textTheme.titleSmall!.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
              Text(
                "Si tu es un escroc, essaie de rajouter une personne qui n'a pas participé. Si tu es démasqué, force à toi",
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
                          if (selectedParticipants[user.username]!)
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
                List<Participant> selectedUsers = widget.users
                    .where((user) => selectedParticipants[user.username] ?? false)
                    .map((user) => Participant(
                  id: user.id,
                  user: user,
                  amount: double.tryParse(amountControllers[user.username]?.text ?? '0') ?? 0,
                ))
                    .toList();
                widget.onParticipantsSelected(selectedUsers);
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
                'Valider les participants',
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