import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spaceshare/widgets/bottom_modal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class EventCodeModal extends StatefulWidget {
  final String code;

  const EventCodeModal({super.key, required this.code});

  @override
  _EventCodeModalState createState() => _EventCodeModalState();
}

class _EventCodeModalState extends State<EventCodeModal> {
  bool _copied = false;

  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() {
      _copied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t(context)!.codeCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomModal(
      scrollController: ScrollController(),
      padding: const EdgeInsets.only(top: 16.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t(context)!.gatherYourCrew,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  t(context)!.shareCodeInstruction,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                InkWell(
                  onTap: _copyCodeToClipboard,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(color: const Color(0xFF373455)),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF373455),
                          offset: Offset(
                            6.0,
                            6.0,
                          ),
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.code,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: _copied
                            ? const Color(0xFF3E908E)
                            : theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _copied ? t(context)!.copied : t(context)!.clickToCopy,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -20,
            left: -60,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/shareEvent.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
