import 'package:flutter/material.dart';
import 'package:nsm/models/balance.dart';

class BalancesChart extends StatelessWidget {
  final List<Balance> balances;

  const BalancesChart({super.key, required this.balances});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: balances.map((balance) {
          return Container(
            width: 60.0,
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
                        width: 40.0,
                        height: (balance.amount.abs() / _maxAmount()) * 200,
                        decoration: BoxDecoration(
                          color:
                              balance.amount >= 0 ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                    height:
                        8.0), // Additional space between the bar and the username
                Text(balance.user.username),
                Text(
                  '${balance.amount.toStringAsFixed(2)} €',
                  style: TextStyle(
                    color: balance.amount >= 0 ? Colors.green : Colors.red,
                  ),
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
