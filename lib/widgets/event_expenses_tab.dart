import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nsm/models/expense.dart';
import 'package:nsm/services/event_websocket_service.dart';
import 'package:intl/intl.dart';

class EventExpensesTab extends StatelessWidget {
  const EventExpensesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventWebsocketProvider>(
      builder: (context, eventProvider, child) {
        final expenses = eventProvider.expenses;
        if (expenses.isEmpty) {
          return const Center(child: Text('No expenses available'));
        }
        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return ExpenseItem(expense: expense);
          },
        );
      },
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final Expense expense;

  const ExpenseItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the column content
                children: [
                  Row(
                    children: [
                      Text(
                        'Dépense du ${dateFormat.format(expense.createdAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (expense.tag.name == 'New')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Text(
                            'New!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    expense.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Payé par ${expense.payers.map((payer) => payer.user.username).join(', ')} pour ${expense.participants.length} pers.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '${expense.amount.toStringAsFixed(2)} €',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
