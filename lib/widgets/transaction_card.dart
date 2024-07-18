import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaceshare/models/transaction.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final websocketEventProvider = Provider.of<EventWebsocketProvider>(context);
    final handleRefund = websocketEventProvider.createRefundFromTransaction;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: theme.textTheme.bodyLarge!.color!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    transaction.from.username,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8.0),
                  CircleAvatar(
                    backgroundImage: NetworkImage(transaction.from.avatar.url),
                    radius: 20.0,
                  ),
                ],
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${t(context)!.owes} ',
                      style: theme.textTheme.bodyLarge,
                    ),
                    TextSpan(
                      text: '${transaction.amount.toStringAsFixed(2)} €',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' ${t(context)!.to}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    transaction.to.username,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8.0),
                  CircleAvatar(
                    backgroundImage: NetworkImage(transaction.to.avatar.url),
                    radius: 20.0,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Divider(
            color: theme.colorScheme.secondaryContainer,
            thickness: 1.0,
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                handleRefund(transaction);
              },
              child: Text(
                t(context)!.settledUp,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
