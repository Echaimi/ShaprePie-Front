import 'package:flutter/material.dart';
import 'package:nsm/services/event_websocket_service.dart';
import 'package:provider/provider.dart';

class EventExpensesTab extends StatelessWidget {
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
            return ListTile(
              title: Text(expense.description),
              subtitle: Text('${expense.amount} €'),
            );
          },
        );
      },
    );
  }
}
