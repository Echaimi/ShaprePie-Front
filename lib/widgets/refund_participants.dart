import 'package:flutter/material.dart';
import 'package:spaceshare/models/user_with_expenses.dart';

import '../models/user.dart';

class RefundParticipants extends StatelessWidget {
  final List<UserWithExpenses> users;
  final Function(User) onUserSelected;

  const RefundParticipants({
    super.key,
    required this.users,
    required this.onUserSelected,
  });

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
              'Sélectionner un utilisateur',
              style: theme.textTheme.titleSmall!.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userWithExpenses = users[index];
                return GestureDetector(
                  onTap: () {
                    onUserSelected(userWithExpenses);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          userWithExpenses.username,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        Text(
                          '${userWithExpenses.refundAmount.toStringAsFixed(2)} €',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
