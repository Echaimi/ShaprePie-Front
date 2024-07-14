import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class ExpenseModalContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              t(context)!.addExpense,
              style: theme.textTheme.titleMedium!.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Center(
            child: Image.asset(
              'lib/assets/images/expense.png',
              height: 150,
            ),
          ),
          const SizedBox(height: 40),
          _buildTextField(t(context)!.amountPlaceholder, context),
          const SizedBox(height: 16.0),
          _buildTextField(t(context)!.forPlaceholder, context),
          const SizedBox(height: 16.0),
          _buildTextField(t(context)!.whoInvolvedPlaceholder, context),
          const SizedBox(height: 16.0),
          _buildTextField(t(context)!.datePlaceholder, context),
          const SizedBox(height: 16.0),
          SizedBox(
            width: 342,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                t(context)!.addExpenseButton,
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 342,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          ),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          filled: true,
          fillColor: theme.colorScheme.primaryContainer,
        ),
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}
