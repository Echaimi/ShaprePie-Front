import 'package:flutter/material.dart';
import '../services/event_websocket_service.dart';
import 'expense_form.dart';

class CreateExpense extends StatelessWidget {
  final int eventId;
  final EventWebsocketProvider eventProvider;

  const CreateExpense(
      {super.key, required this.eventId, required this.eventProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                'Ajouter une dépense',
                style: theme.textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ExpenseForm(
              onSubmit: eventProvider.createExpense,
              users: eventProvider.users,
              eventId: eventId,
            ),
          ],
        ),
      ),
    );
  }
}
