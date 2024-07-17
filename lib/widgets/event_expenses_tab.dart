import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaceshare/models/expense.dart';
import 'package:spaceshare/models/refund.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'expense_details_modal.dart';
import 'refund_details_modal.dart.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class EventExpensesTab extends StatelessWidget {
  const EventExpensesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventWebsocketProvider>(
      builder: (context, eventProvider, child) {
        final expenses = eventProvider.expenses;
        final refunds = eventProvider.refunds;

        if (expenses.isEmpty && refunds.isEmpty) {
          return Center(child: Text(t(context)!.noExpensesAvailable));
        }

        final items = [
          ...expenses.map((e) => {'type': 'expense', 'data': e}),
          ...refunds.map((r) => {'type': 'refund', 'data': r}),
        ];

        items.sort((a, b) {
          final aDate = a['type'] == 'expense'
              ? (a['data'] as Expense).createdAt
              : (a['data'] as Refund).date;
          final bDate = b['type'] == 'expense'
              ? (b['data'] as Expense).createdAt
              : (b['data'] as Refund).date;
          return bDate.compareTo(aDate);
        });

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            if (item['type'] == 'expense') {
              final expense = item['data'] as Expense;
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
            } else {
              final refund = item['data'] as Refund;
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => RefundDetailsModal(
                        refund: refund, eventProvider: eventProvider),
                  );
                },
                child: RefundItem(refund: refund),
              );
            }
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
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.secondaryContainer),
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
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    expense.name,
                    style: theme.textTheme.bodyLarge,
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

class RefundItem extends StatelessWidget {
  final Refund refund;

  const RefundItem({super.key, required this.refund});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.primaryContainer),
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
                  Text(
                    '${t(context)!.refundDate} ${dateFormat.format(refund.date)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${t(context)!.refundFrom} ${refund.from.username} ${t(context)!.to} ${refund.to.username}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: Center(
                child: Text(
                  '${refund.amount.toStringAsFixed(2)} €',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E908E)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
