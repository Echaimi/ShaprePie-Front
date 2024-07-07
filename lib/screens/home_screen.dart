import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:nsm/widgets/EventNotFound.dart';
import 'package:provider/provider.dart';
import '../services/event_service.dart';
import '../providers/auth_provider.dart';
import '../models/event.dart';
import 'package:nsm/widgets/AddButton.dart' as add_button;
import 'package:nsm/widgets/bottom_navigation_bar.dart';
import 'package:nsm/widgets/bottom_modal.dart';
import 'package:nsm/widgets/join_us.dart';
import 'package:nsm/widgets/join_event_modal_content.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class HomeScreen extends StatefulWidget {
  final EventService eventService;

  const HomeScreen({super.key, required this.eventService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  bool _isLoading = false;
  bool _showArchived = false;
  List<Event> _events = [];
  List<Event> _archivedEvents = [];
  String _title = '';

  static const List<String> _routes = [
    '/profile',
    '/',
  ];

  @override
  void initState() {
    super.initState();
    // Initially fetch events if already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  Future<void> _initializeScreen() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      await _fetchEvents();
    }
    setState(() {
      _title = t(context)?.yourEvents ?? 'Your Events';
    });
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Event> allEvents = await widget.eventService.getEvents();
      _events = allEvents.where((event) => event.state == 'active').toList();
      _archivedEvents =
          allEvents.where((event) => event.state == 'archived').toList();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateEventState(int eventId, String state) async {
    try {
      await widget.eventService.updateEventState(eventId, state);
      await _fetchEvents();
    } catch (e) {
      print('Error updating event state: $e');
    }
  }

  void _showArchiveOptions(BuildContext context, Event event) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          if (event.state == 'active')
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _updateEventState(event.id, 'archived');
              },
              child: Text(t(context)?.archiveEvent ?? 'Archive Event'),
            ),
          if (event.state == 'archived')
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _updateEventState(event.id, 'active');
              },
              child: Text(t(context)?.activateEvent ?? 'Activate Event'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(t(context)?.cancel ?? 'Cancel'),
        ),
      ),
    );
  }

  void _showModal(BuildContext context, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BottomModal(
          scrollController: ScrollController(),
          child: child,
        );
      },
    );
  }

  void _onAddButtonPressed() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      _showModal(context, const JoinUs());
      return;
    }
    _showCupertinoActionSheet(context);
  }

  void _showCupertinoActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              context.go('/create-event');
            },
            child: Text(t(context)?.createEvent ?? 'Create Event'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showModal(context, const JoinEventModalContent());
            },
            child: Text(t(context)?.joinEvent ?? 'Join Event'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(t(context)?.cancel ?? 'Cancel'),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }

  String _getCategoryImagePath(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'lib/assets/category/travel.png';
      case 2:
        return 'lib/assets/category/birthday.png';
      case 3:
        return 'lib/assets/category/party.png';
      case 4:
        return 'lib/assets/category/holiday.png';
      case 5:
        return 'lib/assets/category/other.png';
      default:
        return 'lib/assets/category/other.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/backgroundApp.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isAuthenticated) {
              if (!_isLoading && _events.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _fetchEvents();
                });
              }
              return _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: TextButton(
                            onPressed: () async {
                              setState(() {
                                _showArchived = !_showArchived;
                                _isLoading = true;
                                _title = _showArchived
                                    ? t(context)?.archiveEventTitle ??
                                        'Archive Event'
                                    : t(context)?.yourEvents ?? 'Your Events';
                              });
                              await _fetchEvents();
                            },
                            child: Text(
                              _showArchived
                                  ? '${t(context)?.backToEvents ?? 'Back to Events'} (${_events.length})'
                                  : '${t(context)?.archiveEvent ?? 'Archive Event'} (${_archivedEvents.length})',
                              style: TextStyle(color: Colors.pink),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: _showArchived
                                ? _archivedEvents.length
                                : _events.length,
                            itemBuilder: (context, index) {
                              final Event event = _showArchived
                                  ? _archivedEvents[index]
                                  : _events[index];
                              final isCategory3 = event.category.id == 3;
                              return GestureDetector(
                                onTap: () {
                                  context.push('/events/${event.id}');
                                },
                                onLongPress: () {
                                  _showArchiveOptions(context, event);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 342,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.4),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.only(
                                              left: 16,
                                              top: 8,
                                              bottom: 8,
                                              right: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 22),
                                                child: Text(
                                                  event.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 22),
                                                child: Text(
                                                  event.description,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: -20,
                                        top: 0,
                                        bottom: 0,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Image.asset(
                                            _getCategoryImagePath(
                                                event.category.id),
                                            height: isCategory3 ? 55 : 50,
                                            width: isCategory3 ? 55 : 50,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
            } else {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: EventNotFound(),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton:
          add_button.AddButton(onPressed: _onAddButtonPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return BottomNavigationBarWidget(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            onAddButtonPressed: _onAddButtonPressed,
            isProfileScreen: false,
            isAuthenticated: authProvider.isAuthenticated,
            showAuthenticationModal: () => _showModal(context, const JoinUs()),
          );
        },
      ),
    );
  }
}
