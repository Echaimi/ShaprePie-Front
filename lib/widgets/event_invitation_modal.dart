import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nsm/widgets/bottom_modal.dart';

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
      const SnackBar(content: Text('Code copied to clipboard!')),
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
                  'Rassemble ton équipage.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Dis leur simplement d’ouvrir l’app ou de la télécharger et de rejoindre l’évènement avec le code suivant :',
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
                      color: theme.colorScheme.background,
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
                            ? Colors.green
                            : theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _copied ? 'Copié !' : 'Clique sur le code pour copier',
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
