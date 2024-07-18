import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/event_service.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class JoinEventModalContent extends StatefulWidget {
  const JoinEventModalContent({super.key});

  @override
  _JoinEventModalContentState createState() => _JoinEventModalContentState();
}

class _JoinEventModalContentState extends State<JoinEventModalContent> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isServerError = false;
  bool _isSuccess = false;
  bool _hasTriedOnce = false;
  bool _isUserAlreadyInEventError = false;
  String? _eventName;
  String? _eventID;
  late EventService _eventService;

  @override
  void initState() {
    super.initState();
    _eventService = EventService(ApiService());
  }

  bool _isCodeValid(String code) {
    final validCharacters = RegExp(r'^[a-z0-9]+$');
    return code.length >= 6 && validCharacters.hasMatch(code);
  }

  Future<void> _joinEvent() async {
    if (!_isCodeValid(_codeController.text)) {
      setState(() {
        _hasTriedOnce = true;
      });
      _codeFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _isSuccess = false;
      _eventName = null;
      _eventID = null;
      _isUserAlreadyInEventError = false;
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
        if (e.toString().contains('user is already in the event')) {
          _isUserAlreadyInEventError = true;
        } else if (e.toString().contains('failed to find event')) {
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
    if (_isUserAlreadyInEventError) {
      content =
          _buildUserAlreadyInEventErrorContent(context, textTheme, colorScheme);
    } else if (_isServerError && _hasTriedOnce) {
      content = _buildErrorContent(context, textTheme, colorScheme);
    } else if (_isSuccess) {
      content = _buildSuccessContent(context, textTheme, colorScheme);
    } else {
      content = _buildDefaultContent(context, textTheme, colorScheme);
    }

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
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
                  ),
                ],
              ),
            ),
          ),
          if (!_isSuccess)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(context, textTheme, colorScheme),
                    const SizedBox(height: 16),
                    _buildJoinButton(context, textTheme, colorScheme),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('error'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            t(context)!.serverError,
            style: textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            height: 300,
            child: Image.asset(
              'lib/assets/images/404.png',
            ),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Text(
            t(context)!.serverErrorMessage,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('success'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: t(context)!.joinedEvent,
                  style: textTheme.titleMedium,
                ),
                TextSpan(
                  text: '“$_eventName”',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            height: 300,
            child: Image.asset(
              'lib/assets/images/eventJoinSuccess.png',
            ),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Text(
            t(context)!.joinedEventMessage,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 40),
        _buildViewEventButton(context, textTheme, colorScheme),
      ],
    );
  }

  Widget _buildDefaultContent(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('default'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            t(context)!.joinEvent,
            style: textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: SizedBox(
            height: 300,
            child: Image.asset(
              'lib/assets/images/joinEvent.png',
            ),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Text(
            t(context)!.joinEventPrompt,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildUserAlreadyInEventErrorContent(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      key: const ValueKey('userAlreadyInEventError'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            t(context)!.userAlreadyInEventError,
            style: textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            height: 300,
            child: Image.asset(
              'lib/assets/images/alreadyInEvent.png',
            ),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Text(
            t(context)!.userAlreadyInEventErrorMessage,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return TextField(
      controller: _codeController,
      focusNode: _codeFocusNode,
      decoration: InputDecoration(
        labelText: t(context)!.eventCode,
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
        errorText: _hasTriedOnce && !_isCodeValid(_codeController.text)
            ? t(context)!.codeTooShort
            : null,
      ),
      style: textTheme.bodyMedium,
      onChanged: (text) {
        setState(() {});
      },
    );
  }

  Widget _buildJoinButton(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _joinEvent,
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.surface,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(
                color: textTheme.bodyLarge?.color,
              )
            : Text(
                t(context)!.join,
              ),
      ),
    );
  }

  Widget _buildViewEventButton(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _viewEvent,
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.surface,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(
          t(context)!.viewEvent,
        ),
      ),
    );
  }
}
