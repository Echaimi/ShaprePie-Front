import 'package:flutter/material.dart';
import 'package:nsm/services/event_websocket_service.dart';
import 'package:provider/provider.dart';

class ExpenseConcernedBy extends StatefulWidget {
  @override
  _ExpenseConcernedByState createState() => _ExpenseConcernedByState();
}

class _ExpenseConcernedByState extends State<ExpenseConcernedBy> {
  final TextEditingController searchController = TextEditingController();
  final Map<String, bool> selectedParticipants = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Qui a khalass ?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Rechercher un participant', searchController, context),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: _selectAll,
              child: Text(
                'Tout sélectionner',
                style: theme.textTheme.bodyText1?.copyWith(
                  color: theme.colorScheme.secondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: _resetSelection,
              child: Text(
                'Réinitialiser',
                style: theme.textTheme.bodyText1?.copyWith(
                  color: theme.colorScheme.secondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Consumer<EventWebsocketProvider>(
                builder: (context, eventProvider, child) {
                  final users = eventProvider.users;
                  if (users.isEmpty) {
                    return const Center(child: Text('No users available'));
                  }
                  for (var user in users) {
                    if (!selectedParticipants.containsKey(user.username)) {
                      selectedParticipants[user.username] = false;
                    }
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return CheckboxListTile(
                        title: Text(
                          user.username,
                          style: theme.textTheme.bodyText1?.copyWith(color: Colors.white),
                        ),
                        value: selectedParticipants[user.username],
                        onChanged: (bool? value) {
                          setState(() {
                            selectedParticipants[user.username] = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: theme.colorScheme.secondary,
                        checkColor: Colors.white,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Logique pour valider les payeurs
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  'Valider les payeurs',
                  style: theme.textTheme.bodyText1?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAll() {
    setState(() {
      selectedParticipants.updateAll((key, value) => true);
    });
  }

  void _resetSelection() {
    setState(() {
      selectedParticipants.updateAll((key, value) => false);
    });
  }

  Widget _buildTextField(String label, TextEditingController controller, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
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
          labelStyle: theme.textTheme.bodyText2?.copyWith(color: Colors.white),
          filled: true,
          fillColor: theme.colorScheme.primaryContainer,
        ),
        style: theme.textTheme.bodyText2?.copyWith(color: Colors.white),
      ),
    );
  }
}