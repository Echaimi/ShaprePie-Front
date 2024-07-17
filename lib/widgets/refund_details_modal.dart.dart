import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spaceshare/models/refund.dart';
import 'package:spaceshare/widgets/bottom_modal.dart';
import '../services/event_websocket_service.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class RefundDetailsModal extends StatelessWidget {
  final Refund refund;
  final EventWebsocketProvider eventProvider;

  const RefundDetailsModal(
      {super.key, required this.refund, required this.eventProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BottomModal(
      scrollController: ScrollController(),
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t(context)!.refundDetails,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '${t(context)!.refundDate} ${dateFormat.format(refund.date)}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      border: Border.all(color: const Color(0xFF373455)),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF373455),
                          offset: Offset(6.0, 6.0),
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            '${refund.amount.toStringAsFixed(2)} €',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            '${t(context)!.refundFrom} ${refund.from.username} ${t(context)!.to} ${refund.to.username}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.pop();
                            context.go(
                                '/events/${refund.id}/refunds/${refund.id}/edit');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            t(context)!.edit,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            eventProvider.deleteRefund(refund.id);
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            t(context)!.delete,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      t(context)!.details,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...[
                      {
                        'label': t(context)!.refundFrom,
                        'value': refund.from.username
                      },
                      {
                        'label': t(context)!.refundTo,
                        'value': refund.to.username
                      },
                      {
                        'label': t(context)!.amount,
                        'value': '${refund.amount.toStringAsFixed(2)} €'
                      },
                    ].map((detail) => Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    detail['label']!,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    detail['value']!,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          theme.textTheme.bodyLarge?.fontSize ??
                                              14 + 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
