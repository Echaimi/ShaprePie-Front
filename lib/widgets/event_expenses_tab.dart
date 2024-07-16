import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaceshare/models/expense.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'expense_details_modal.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class EventExpensesTab extends StatelessWidget {
  const EventExpensesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventWebsocketProvider>(
      builder: (context, eventProvider, child) {
        final expenses = eventProvider.expenses;
        if (expenses.isEmpty) {
          return Center(child: Text(t(context)!.noExpensesAvailable));
        }
        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => ExpenseDetailsModal(
                      expense: expense, eventProvider: eventProvider),
                );
              },
              child: ExpenseItem(expense: expense),
            );
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        '${t(context)!.expenseDate} ${dateFormat.format(expense.date)}',
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
                          child: Text(
                            t(context)!.newExpense,
                            style: const TextStyle(color: Colors.white),
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
                    '${t(context)!.paidBy} ${expense.payers.map((payer) => payer.user.username).join(', ')} ${t(context)!.foru} ${expense.participants.length} ${t(context)!.persons}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: Center(
                child: Text(
                  '${expense.amount.toStringAsFixed(2)} €',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
