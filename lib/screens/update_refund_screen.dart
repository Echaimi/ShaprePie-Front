import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spaceshare/models/refund.dart';
import 'package:spaceshare/services/event_websocket_service.dart';

import '../widgets/refundForm.dart';

class UpdateRefundScreen extends StatelessWidget {
  final Refund refund;
  final EventWebsocketProvider eventProvider;

  const UpdateRefundScreen({
    super.key,
    required this.refund,
    required this.eventProvider,
  });

  @override
  Widget build(BuildContext context) {
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
                  eventProvider.updateRefund(refund.id, data);
                },
                initialRefund: refund,
                isUpdate: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
