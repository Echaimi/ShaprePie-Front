import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:spaceshare/widgets/expense_form.dart';

class CreateExpenseScreen extends StatelessWidget {
  const CreateExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventWebsocketProvider = Provider.of<EventWebsocketProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 35.0),
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: ExpenseForm(
                onSubmit: (data) {
                  eventWebsocketProvider.createExpense(data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
