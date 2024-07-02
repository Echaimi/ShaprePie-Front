import 'package:flutter/material.dart';
import 'package:nsm/services/event_websocket_service.dart';
import 'package:nsm/widgets/balances_chart.dart';
import 'package:nsm/widgets/transaction_card.dart';
import 'package:provider/provider.dart';

class EventBalanceTab extends StatelessWidget {
  const EventBalanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventWebsocketProvider>(
      builder: (context, eventProvider, child) {
        final balances = eventProvider.balances;
        final transactions = eventProvider.transactions;

        if (balances.isEmpty && transactions.isEmpty) {
          return const Center(
              child: Text('No balances or transactions available'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '<-- Fais défiler pour voir tout le monde -->',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              BalancesChart(balances: balances),
              const SizedBox(height: 32),
              Text(
                'Qui raque ?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Column(
                children: transactions.map((transaction) {
                  return Column(
                    children: [
                      TransactionCard(transaction: transaction),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
