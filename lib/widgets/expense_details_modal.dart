import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spaceshare/models/expense.dart';
import 'package:spaceshare/widgets/bottom_modal.dart';
import '../services/event_websocket_service.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class ExpenseDetailsModal extends StatelessWidget {
  final Expense expense;
  final EventWebsocketProvider eventProvider;

  const ExpenseDetailsModal(
      {super.key, required this.expense, required this.eventProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BottomModal(
      scrollController: ScrollController(),
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  expense.name,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '${t(context)!.expenseDate} ${dateFormat.format(expense.date)}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      border: Border.all(color: const Color(0xFF373455)),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF373455),
                          offset: Offset(6.0, 6.0),
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            '${expense.amount.toStringAsFixed(2)} €',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            '${t(context)!.totalFor} ${expense.participants.length} ${t(context)!.persons}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.go(
                                '/events/${expense.eventId}/expenses/${expense.id}/edit');
                          },
                          child: Text(
                            t(context)!.edit,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            eventProvider.deleteExpense(expense.id);
                            context.pop(context);
                          },
                          child: Text(
                            t(context)!.delete,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      t(context)!.paidBy,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    ...expense.payers.map(
                      (payer) => Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: ListTile(
                          title: Text(payer.user.username,
                              style: theme.textTheme.bodyMedium),
                          trailing: Text(
                            '${payer.amount.toStringAsFixed(2)} €',
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      t(context)!.participants,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    ...expense.participants.map(
                      (participant) => Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: ListTile(
                          title: Text(participant.user.username,
                              style: theme.textTheme.bodyMedium),
                          trailing: Text(
                            '${participant.amount.toStringAsFixed(2)} €',
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
