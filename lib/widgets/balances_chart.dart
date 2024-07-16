import 'package:flutter/material.dart';
import 'package:spaceshare/models/balance.dart';

class BalancesChart extends StatelessWidget {
  final List<Balance> balances;

  const BalancesChart({super.key, required this.balances});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: balances.map((balance) {
          return Container(
            width: 76.0,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 200.0,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 60.0,
                        height: (balance.amount.abs() / _maxAmount()) * 200,
                        decoration: BoxDecoration(
                          color: balance.amount >= 0
                              ? const Color(0xFF3E908E)
                              : theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(balance.user.username),
                Text(
                  '${balance.amount >= 0 ? '+' : ''}${balance.amount.toStringAsFixed(2)} €',
                  style: TextStyle(
                      color: balance.amount >= 0
                          ? const Color(0xFF3E908E)
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  double _maxAmount() {
    return balances.map((b) => b.amount.abs()).reduce((a, b) => a > b ? a : b);
  }
}
