import 'package:flutter/material.dart';
import 'package:spaceshare/models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                transaction.from.username,
                style: Theme.of(context).textTheme.bodyLarge,
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
                  text: 'doit ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                TextSpan(
                  text: '${transaction.amount.toStringAsFixed(2)} €',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' à',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                transaction.to.username,
                style: Theme.of(context).textTheme.bodyLarge,
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
    );
  }
}
