import 'package:flutter/material.dart';
import 'package:spaceshare/models/refund.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/refund_form.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

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
                child: Text(
                  t(context)?.close ?? 'Fermer',
                  style: const TextStyle(color: Colors.white),
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
