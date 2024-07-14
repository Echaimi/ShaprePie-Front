import 'package:flutter/material.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:spaceshare/widgets/balances_chart.dart';
import 'package:spaceshare/widgets/transaction_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class EventBalanceTab extends StatelessWidget {
  const EventBalanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventWebsocketProvider>(
      builder: (context, eventProvider, child) {
        final balances = eventProvider.balances;
        final transactions = eventProvider.transactions;

        if (balances.isEmpty && transactions.isEmpty) {
          return Center(
            child: Text(t(context)!.noBalancesOrTransactionsAvailable),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  t(context)!.scrollToSeeEveryone,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              BalancesChart(balances: balances),
              const SizedBox(height: 32),
              Text(
                t(context)!.whoPays,
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
