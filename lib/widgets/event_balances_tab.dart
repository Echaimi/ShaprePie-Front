import 'package:flutter/material.dart';
import 'package:nsm/services/event_websocket_service.dart';
import 'package:provider/provider.dart';

class EventBalanceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EventWebsocketProvider>(
      builder: (context, eventProvider, child) {
        final expenses = eventProvider.expenses;
        if (expenses.isEmpty) {
          return const Center(child: Text('No expenses available'));
        }
        final totalExpenses =
            expenses.fold(0.0, (sum, expense) => sum + expense.amount);
        return Center(
          child: Text('Total Spent: $totalExpenses €'),
        );
      },
    );
  }
}
