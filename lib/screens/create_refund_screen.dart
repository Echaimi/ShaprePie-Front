import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:spaceshare/widgets/refund_form.dart';

class CreateRefundScreen extends StatelessWidget {
  const CreateRefundScreen(
      {super.key, required EventWebsocketProvider eventProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventWebsocketProvider = Provider.of<EventWebsocketProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF3E908E),
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
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: RefundForm(
                onSubmit: (data) {
                  eventWebsocketProvider.createRefund(data);
                },
                isUpdate: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
