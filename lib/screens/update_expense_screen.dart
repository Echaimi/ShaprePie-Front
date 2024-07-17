import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:spaceshare/widgets/expense_form.dart';
import 'package:go_router/go_router.dart';

class UpdateExpenseScreen extends StatelessWidget {
  final int expenseId;
  const UpdateExpenseScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventWebsocketProvider = Provider.of<EventWebsocketProvider>(context);
    final expense = eventWebsocketProvider.getExpenseById(expenseId);

    return Scaffold(
      backgroundColor: const Color(0xFF8685EF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 35.0),
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: () {
                  context.pop();
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
                  eventWebsocketProvider.updateExpense(expenseId, data);
                  context.pop();
                },
                initialExpense: expense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
