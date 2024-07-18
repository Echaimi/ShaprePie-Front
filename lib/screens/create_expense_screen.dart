import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:spaceshare/widgets/expense_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class CreateExpenseScreen extends StatelessWidget {
  const CreateExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    final eventWebsocketProvider = Provider.of<EventWebsocketProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF8685EF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 35.0),
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  t(context)?.close ?? 'Fermer',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: ExpenseForm(
                onSubmit: (data) {
                  eventWebsocketProvider.createExpense(data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
