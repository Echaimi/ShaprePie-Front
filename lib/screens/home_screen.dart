import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:spaceshare/widgets/event_not_found.dart';
import 'package:spaceshare/widgets/create_event_modal_content.dart';
import 'package:provider/provider.dart';
import '../services/event_service.dart';
import '../providers/auth_provider.dart';
import '../models/event.dart';
import 'package:spaceshare/widgets/add_button.dart' as add_button;
import 'package:spaceshare/widgets/bottom_modal.dart';
import 'package:spaceshare/widgets/join_us.dart';
import 'package:spaceshare/widgets/join_event_modal_content.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skeletonizer/skeletonizer.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class HomeScreen extends StatefulWidget {
  final EventService eventService;

  const HomeScreen({super.key, required this.eventService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _showArchived = false;
  List<Event> _events = [];
  List<Event> _archivedEvents = [];

  static const List<String> _routes = [
    '/profile',
    '/',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  Future<void> _initializeScreen() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      await _fetchEvents();
    }
    setState(() {});
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;

    if (event.author.id != currentUserId) {
      Fluttertoast.showToast(
        msg: "Il faut être le commandant de bord de cet event pour faire cela",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(context).colorScheme.surface,
        textColor: Theme.of(context).textTheme.bodySmall?.color,
        fontSize: Theme.of(context).textTheme.bodySmall?.fontSize ?? 16.0,
      );
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          if (event.state == 'active')
            CupertinoActionSheetAction(
              onPressed: () {
                context.pop();
                _updateEventState(event.id, 'archived');
              },
              child: Text(t(context)?.archiveEvent ?? 'Archiver l\'événement'),
            ),
          if (event.state == 'archived')
            CupertinoActionSheetAction(
              onPressed: () {
                context.pop();
                _updateEventState(event.id, 'active');
              },
              child: Text(t(context)?.activateEvent ?? 'Activer l\'événement'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            context.pop();
          },
          child: Text(t(context)?.cancel ?? 'Annuler'),
        ),
      ),
    );
  }

  void _showModal(BuildContext context, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              context.pop();
              _showModal(context, const CreateEventModalContent());
            },
            child: Text(t(context)?.createEvent ?? 'Créer un événement'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              context.pop();
              _showModal(context, const JoinEventModalContent());
            },
            child: Text(t(context)?.joinEvent ?? 'Rejoindre un événement'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            context.pop();
          },
          child: Text(t(context)?.cancel ?? 'Annuler'),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {});
    context.go(_routes[index]);
  }

  String _getCategoryImagePath(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'lib/assets/images/category/travel.png';
      case 2:
        return 'lib/assets/images/category/birthday.png';
      case 3:
        return 'lib/assets/images/category/party.png';
      case 4:
        return 'lib/assets/images/category/holiday.png';
      case 5:
        return 'lib/assets/images/category/other.png';
      default:
        return 'lib/assets/images/category/other.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userAvatar = authProvider.user?.avatar.url;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: IconButton(
          icon: Text(
            _showArchived
                ? '${t(context)?.backToEvents ?? 'Retour aux événements'} (${_events.length})'
                : '${t(context)?.archiveEvent ?? 'Événements archivés'} (${_archivedEvents.length})',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          onPressed: () async {
            setState(() {
              _showArchived = !_showArchived;
              _isLoading = true;
            });
            await _fetchEvents();
          },
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: NetworkImage(userAvatar ?? ''),
            ),
            onPressed: () {
              context.go('/profile');
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated) {
            if (!_isLoading && _events.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fetchEvents();
              });
            }
            return _isLoading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: 20,
                            width: 180,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Skeletonizer(
                          enabled: true,
                          child: Column(
                            children: List.generate(
                              5,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  height: 80,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Icon(Icons.rocket,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Tes évènements',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _showArchived
                            ? _archivedEvents.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      'Aucun évènement dans cette galaxie pour l\'instant',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0),
                                    itemCount: _archivedEvents.length,
                                    itemBuilder: (context, index) {
                                      final Event event =
                                          _archivedEvents[index];
                                      return _buildEventItem(context, event);
                                    },
                                  )
                            : _events.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      'Aucun évènement dans cette galaxie pour l\'instant',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0),
                                    itemCount: _events.length,
                                    itemBuilder: (context, index) {
                                      final Event event = _events[index];
                                      return _buildEventItem(context, event);
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
      floatingActionButton:
          add_button.AddButton(onPressed: _onAddButtonPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEventItem(BuildContext context, Event event) {
    final isCategory3 = event.category.id == 3;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        final result = await context.push('/events/${event.id}');
        if (result == true) {
          _fetchEvents();
        }
      },
      onLongPress: () {
        _showArchiveOptions(context, event);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.only(left: 40, right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.userCount} personne${event.userCount! > 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall,
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
                  _getCategoryImagePath(event.category.id),
                  height: isCategory3 ? 55 : 50,
                  width: isCategory3 ? 55 : 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
