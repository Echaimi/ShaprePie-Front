import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_form.dart';
import 'package:nsm/services/event_websocket_service.dart'; // Assurez-vous que le chemin d'importation est correct

class CreateExpense extends StatelessWidget {
  final int eventId;
  const CreateExpense({super.key, required this.eventId});

  void handleCreateExpense(BuildContext context, Map<String, dynamic> data) {
    final eventProvider = Provider.of<EventWebsocketProvider>(context, listen: false);
    // eventProvider.createExpense(data);
    print(eventProvider.users);
  }

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
              'Ajouter une dépense',
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
          ExpenseForm(onSubmit: (data) => handleCreateExpense(context, data)),
        ],
      ),
    );
  }
}
