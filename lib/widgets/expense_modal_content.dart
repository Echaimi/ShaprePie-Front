import 'package:flutter/material.dart';

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
          _buildTextField('Montant (00.00€)', context),
          const SizedBox(height: 16.0),
          _buildTextField('Pour', context),
          const SizedBox(height: 16.0),
          _buildTextField('Concerne qui ?', context),
          const SizedBox(height: 16.0),
          _buildTextField('Fait le (00/00/0000)', context),
          const SizedBox(height: 16.0),
          SizedBox(
            width: 342,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                'Ajouter la dépense',
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
