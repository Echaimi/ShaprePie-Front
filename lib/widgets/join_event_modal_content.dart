import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/event_service.dart';
import '../services/api_service.dart';
import 'dart:convert';

class JoinEventModalContent extends StatefulWidget {
  const JoinEventModalContent({Key? key}) : super(key: key);

  @override
  _JoinEventModalContentState createState() => _JoinEventModalContentState();
}

class _JoinEventModalContentState extends State<JoinEventModalContent> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isServerError = false;
  bool _isSuccess = false;
  bool _hasTriedOnce = false;
  String? _eventName;
  String? _eventID;
  late EventService _eventService;

  @override
  void initState() {
    super.initState();
    _eventService = EventService(ApiService());
  }

  Future<void> _joinEvent() async {
    setState(() {
      _isLoading = true;
      _isSuccess = false;
      _eventName = null;
      _eventID = null;
    });

    try {
      final response = await _eventService.joinEvent(_codeController.text);
      final jsonResponse = json.decode(response);
      setState(() {
        _eventName = jsonResponse['data']['name'];
        _eventID = jsonResponse['data']['ID'].toString();
        _isSuccess = true;
        _isServerError = false;
      });
    } catch (e) {
      setState(() {
        if (e.toString().contains('User is already in the event')) {
          _isServerError = true;
        } else {
          _isServerError = false;
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
        _hasTriedOnce = true;
      });
    }
  }

  void _viewEvent() {
    if (_eventID != null) {
      context.go('/events/$_eventID');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget content;
    if (_isServerError && _hasTriedOnce) {
      content = Column(
        key: const ValueKey('error'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Rejoindre un évènement',
              style: textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Image.asset(
              'lib/assets/images/404.png',
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Oups ! Il semblerait que tu te situes déjà sur la planète que tu recherches essaie une autre répertoriée dans ce système solaire.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black.withOpacity(0.1),
              labelText: 'Code de l\'évènement',
              labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.secondaryContainer,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.4),
                  width: 1.0,
                ),
              ),
            ),
            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _joinEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: colorScheme.secondaryContainer,
                    width: 1.0,
                  ),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      'Rejoindre',
                      style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
            ),
          ),
        ],
      );
    } else if (_isSuccess) {
      content = Column(
        key: const ValueKey('success'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Vous avez rejoint\n',
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  TextSpan(
                    text: '“$_eventName”',
                    style: textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Image.asset(
              'lib/assets/images/eventJoinSuccess.png',
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Félicitations ! La planète que tu recherches est bien répertoriée dans ce système solaire.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _viewEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: colorScheme.secondaryContainer,
                    width: 1.0,
                  ),
                ),
              ),
              child: Text(
                'Voir l\'évènement',
                style: textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    } else {
      content = Column(
        key: const ValueKey('default'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Rejoindre un évènement',
              style: textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Le créateur de l\'évènement t\'as envoyé un code pour rejoindre la partie ! Rien reçu ? Contacte le directement',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Image.asset(
              'lib/assets/images/joinEvent.png',
            ),
          ),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Code de l\'évènement',
              labelStyle: TextStyle(color: colorScheme.primary),
              fillColor: Colors.blueGrey.withOpacity(0.2),
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _joinEvent,
              style: ElevatedButton.styleFrom(
                  foregroundColor: colorScheme.surface,
                  backgroundColor: colorScheme.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textStyle: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: textTheme.bodyLarge?.color,
                    )
                  : const Text(
                      'Rejoindre',
                    ),
            ),
          ),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}
