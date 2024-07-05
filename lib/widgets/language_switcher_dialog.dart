import 'package:flutter/material.dart';
import 'package:nsm/providers/LanguageProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSwitcherModal extends StatefulWidget {
  final VoidCallback onClose;

  const LanguageSwitcherModal({super.key, required this.onClose});

  @override
  _LanguageSwitcherModalState createState() => _LanguageSwitcherModalState();
}

class _LanguageSwitcherModalState extends State<LanguageSwitcherModal> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              _overlayEntry?.remove();
              widget.onClose();
            },
            child: Container(
              color: const Color(0x66000000),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF373455),
                    offset: Offset(
                      8.0,
                      8.0,
                    ),
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close,
                            color: Theme.of(context).colorScheme.secondary),
                        onPressed: () {
                          _overlayEntry?.remove();
                          widget.onClose();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _LanguageSwitcherContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _LanguageSwitcherContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final t = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t!.chooseLanguage,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                languageProvider.setLocale(const Locale('en'));
                _closeModal(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('lib/assets/icons/uk_flag.png', width: 50),
                  const SizedBox(height: 16),
                  Text(
                    t.english,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                languageProvider.setLocale(const Locale('fr'));
                _closeModal(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('lib/assets/icons/fr_flag.png', width: 50),
                  const SizedBox(height: 16),
                  Text(
                    t.french,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _closeModal(BuildContext context) {
    Navigator.of(context).pop();
  }
}
