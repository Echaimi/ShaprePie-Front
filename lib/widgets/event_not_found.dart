import 'package:flutter/material.dart';
import 'package:spaceshare/widgets/bottom_modal.dart';
import 'package:spaceshare/widgets/join_us.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class EventNotFound extends StatelessWidget {
  const EventNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t(context)!.exploreTheGalaxy, style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(t(context)!.manageExpensesWithEase, style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          t(context)!.joinUsJourney,
          style: textTheme.bodyLarge,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  builder: (BuildContext context) {
                    return BottomModal(
                      scrollController: ScrollController(),
                      child: const JoinUs(),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(t(context)!.joinUsButton),
            ),
          ],
        )
      ],
    );
  }
}
