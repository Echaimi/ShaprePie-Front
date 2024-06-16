import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import 'package:nsm/widgets/AddButton.dart' as add_button;
import 'package:nsm/widgets/bottom_navigation_bar.dart';
import 'package:nsm/widgets/bottom_modal.dart';
import 'package:nsm/widgets/join_event_modal_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  static const List<String> _routes = [
    '/profile',
    '/',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.fetchEvents();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }

  void _onAddButtonPressed() {
    _showCupertinoActionSheet(context);
  }

  void _showJoinEventModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BottomModal(
          scrollController: ScrollController(),
          child: const JoinEventModalContent(),
        );
      },
    );
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
              _showJoinEventModal(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Consumer<EventProvider>(
          builder: (context, eventProvider, child) {
            if (eventProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (eventProvider.events.isEmpty) {
              return const Center(child: Text('No events found.'));
            }

            return ListView.builder(
              itemCount: eventProvider.events.length,
              itemBuilder: (context, index) {
                final Event event = eventProvider.events[index];
                return ListTile(
                  title: Text(event.name),
                  subtitle: Text(event.description),
                  onTap: () {
                    context.go('/events/${event.id}');
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton:
          add_button.AddButton(onPressed: _onAddButtonPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onAddButtonPressed: _onAddButtonPressed,
      ),
    );
  }
}
