import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'event_screen.dart';

class HomeScreen extends StatefulWidget {
  final EventService eventService;

  const HomeScreen({super.key, required this.eventService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  List<Event> _events = [];

  static const List<String> _routes = [
    '/profile',
    '/',
  ];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _checkAuthentication();
    if (_isAuthenticated) {
      await _fetchEvents();
    }
  }

  Future<void> _checkAuthentication() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.isAuthenticated();
    setState(() {
      _isAuthenticated = isAuthenticated;
    });
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _events = await widget.eventService.getEvents();
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    if (!_isAuthenticated) {
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
            child: const Text('Créer un évènement'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showModal(context, const JoinEventModalContent());
            },
            child: const Text('Rejoindre un évènement'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annuler'),
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
          'Tes évènements',
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
        child: _isAuthenticated
            ? _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: const EventNotFound(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final Event event = _events[index];
                                final isCategory3 = event.category.id == 3;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EventScreen(eventId: event.id),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            width: 342,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.4),
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                      )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: EventNotFound(),
                  ),
                ],
              ),
      ),
      floatingActionButton:
          add_button.AddButton(onPressed: _onAddButtonPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onAddButtonPressed: _onAddButtonPressed,
        isProfileScreen: false,
        isAuthenticated: _isAuthenticated,
        showAuthenticationModal: () => _showModal(context, const JoinUs()),
      ),
    );
  }
}
