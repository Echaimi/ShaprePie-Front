import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nsm/services/event_websocket_service.dart';
import 'package:nsm/widgets/AddButton.dart';
import 'package:nsm/widgets/bottom_modal.dart';
import 'package:nsm/widgets/event_balances_tab.dart';
import 'package:nsm/widgets/event_expenses_tab.dart';
import 'package:nsm/widgets/event_users_tab.dart';
import 'package:nsm/widgets/expense_modal_content.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nsm/widgets/refound_modal_content.dart';

class EventScreen extends StatefulWidget {
  final int eventId;

  const EventScreen({required this.eventId, super.key});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  EventWebsocketProvider? _eventProvider;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    final webSocketService = WebSocketService(
        '${dotenv.env['API_WS_URL']}/ws/events/${widget.eventId}');
    await Future.delayed(const Duration(seconds: 1));

    _eventProvider = EventWebsocketProvider(webSocketService);
    setState(() {}); // Appel pour reconstruire le widget après l'initialisation
  }

  void deleteEvent() {
    // Implémentez la logique de suppression de l'événement
  }

  void _showAddOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return BottomModal(
                    scrollController: ScrollController(),
                    child: ExpenseModalContent(),
                  );
                },
              );
            },
            child: const Text('Ajouter une dépense'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return BottomModal(
                    scrollController: ScrollController(),
                    child: RefundModalContent(),
                  );
                },
              );
            },
            child: const Text('Ajouter un remboursement'),
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
    if (_eventProvider == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProvider<EventWebsocketProvider>(
      create: (context) => _eventProvider!,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete event'),
                        content: const Text(
                            'Are you sure you want to delete this event?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: deleteEvent,
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: Consumer<EventWebsocketProvider>(
            builder: (context, eventProvider, child) {
              final event = eventProvider.event;
              if (event == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.white, width: 4.0),
                      ),
                      child: const Center(
                        child: Text(
                          '10€',
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: TabBar(
                        indicator:
                            const BoxDecoration(), // No indicator decoration
                        labelColor: Theme.of(context)
                            .colorScheme
                            .secondary, // Active tab color
                        unselectedLabelColor:
                            Colors.white, // Inactive tab color
                        labelStyle: const TextStyle(
                            fontSize: 14.0), // Smaller text size
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.person),
                            text: 'Personnes',
                          ),
                          Tab(
                            icon: Icon(Icons.attach_money),
                            text: 'Dépenses',
                          ),
                          Tab(
                            icon: Icon(Icons.balance),
                            text: 'Équilibre',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: TabBarView(
                        children: [
                          const EventUsersTab(),
                          const EventExpensesTab(),
                          EventBalanceTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.white, width: 1.0)),
            ),
            child: BottomAppBar(
              color: Theme.of(context).colorScheme.background,
              child: const SizedBox(
                height: 60.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text("J'ai dépensé"),
                        Text('0 €'),
                      ],
                    ),
                    Column(
                      children: [
                        Text('On me doit'),
                        Text('0 €'),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton:
              AddButton(onPressed: () => _showAddOptions(context)),
        ),
      ),
    );
  }
}
