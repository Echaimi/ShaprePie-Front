import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'expense_form.dart';
import 'package:spaceshare/services/event_websocket_service.dart';

class UpdateExpense extends StatelessWidget {
  final int eventId;
  final Expense expense;
  final EventWebsocketProvider eventProvider;

  const UpdateExpense(
      {super.key,
      required this.eventId,
      required this.expense,
      required this.eventProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    print(expense.tag.id);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'Mettre à jour la dépense',
                style: theme.textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ExpenseForm(
              onSubmit: (data) {
                eventProvider.updateExpense(expense.id, data);
              },
              users: eventProvider.users,
              eventId: eventId,
              initialExpense: expense,
            ),
          ],
        ),
      ),
    );
  }
}
