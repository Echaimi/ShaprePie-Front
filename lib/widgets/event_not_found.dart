import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class EventNotFound extends StatelessWidget {
  const EventNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final containerColor = colorScheme.primaryContainer;

    return Container(
      width: 342,
      height: 152,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: colorScheme.primary),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary,
            offset: const Offset(8, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/noEventFound.png',
                width: 64,
                height: 64,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  t(context)!.createOrJoinEvent,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t(context)!.enjoyTools,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
