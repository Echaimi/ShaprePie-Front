import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:spaceshare/providers/auth_provider.dart';
import 'package:spaceshare/services/api_service.dart';
import 'package:spaceshare/services/event_service.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:spaceshare/widgets/AddButton.dart';
import 'package:spaceshare/widgets/bottom_modal.dart';
import 'package:spaceshare/widgets/event_balances_tab.dart';
import 'package:spaceshare/widgets/event_expenses_tab.dart';
import 'package:spaceshare/widgets/event_invitation_modal.dart';
import 'package:spaceshare/widgets/event_users_tab.dart';
import 'package:spaceshare/widgets/expense_modal_content.dart';
import 'package:spaceshare/widgets/update_event_modal_content.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spaceshare/widgets/refound_modal_content.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/create_expense.dart';
import '../widgets/full_screen_modal.dart'; // Import FullScreenModal

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class EventScreen extends StatefulWidget {
  final int eventId;

  const EventScreen({required this.eventId, super.key});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  EventWebsocketProvider? _eventProvider;
  EventService eventService = EventService(ApiService());

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    final webSocketService = WebSocketService(
        '${dotenv.env['API_WS_URL']}/ws/events/${widget.eventId}');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Future.delayed(const Duration(seconds: 1));

    _eventProvider = EventWebsocketProvider(
      webSocketService,
      authProvider,
    );
    setState(() {});
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

  Future<void> _deleteEvent(BuildContext context) async {
    if (_eventProvider != null && _eventProvider!.event != null) {
      eventService.deleteEvent(_eventProvider!.event!.id);
      context.pop(true); // Return true to indicate a change
      context.go('/');
    }
  }

  Future<void> _updateEventState(int eventId, String state) async {
    try {
      await eventService.updateEventState(eventId, state);
      setState(() {
        _eventProvider!.event!.updateState(state);
      });
      context.pop(true); // Return true to indicate a change
    } catch (e) {
      print('Error updating event state: $e');
    }
  }

  void _archiveEvent(BuildContext context) {
    if (_eventProvider != null && _eventProvider!.event != null) {
      final newState =
          _eventProvider!.event!.state == 'active' ? 'archived' : 'active';
      _updateEventState(_eventProvider!.event!.id, newState);
    }
  }

  void _showAddOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              context.pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenModal(
                    child: CreateExpense(
                      eventId: widget.eventId,
                      eventProvider: Provider.of<EventWebsocketProvider>(
                          context,
                          listen: false),
                    ),
                  ),
                ),
              );
            },
            child: Text(t(context)!.addExpense),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              context.pop();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenModal(
                    child: RefundModalContent(),
                  ),
                ),
              );
            },
            child: Text(t(context)!.addRefund),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            context.pop();
          },
          child: Text(t(context)!.cancel),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_eventProvider == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isArchived = _eventProvider!.event!.state == 'archived';

    return ChangeNotifierProvider<EventWebsocketProvider>(
      create: (context) => _eventProvider!,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {
                  final eventCode = _eventProvider?.event?.code;

                  if (eventCode != null && eventCode.isNotEmpty) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return EventCodeModal(
                          code: eventCode,
                        );
                      },
                    );
                  }
                },
              ),
              if (_eventProvider!.event!.author.id ==
                  authProvider.user!.id) ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    if (isArchived) {
                      Fluttertoast.showToast(
                        msg:
                            "La planète que vous essayez de consulter a été archivée et n'est plus en mission",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        textColor: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize ??
                                16.0,
                      );
                    } else {
                      _showModal(
                        context,
                        UpdateEventModalContent(
                          eventId: _eventProvider!.event!.id,
                          initialEventName: _eventProvider!.event!.name,
                          initialDescription:
                              _eventProvider!.event!.description,
                          initialCategoryId: _eventProvider!.event!.category.id,
                          eventProvider: _eventProvider!,
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        actions: <CupertinoActionSheetAction>[
                          CupertinoActionSheetAction(
                            onPressed: () {
                              _deleteEvent(context);
                              context.pop();
                            },
                            child: const Text('Supprimer l\'évènement'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              _archiveEvent(context);
                              context.pop();
                            },
                            child: Text(
                              _eventProvider!.event!.state == 'active'
                                  ? 'Archiver l\'évènement'
                                  : 'Activer l\'évènement',
                            ),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () {
                            context.pop();
                          },
                          child: const Text('Annuler'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          body: Consumer<EventWebsocketProvider>(
            builder: (context, eventProvider, child) {
              final theme = Theme.of(context);

              final event = eventProvider.event;
              final users = eventProvider.users;
              final totalExpenses = eventProvider.totalExpenses;
              final usersCount = users.length;
              final expensesCount = eventProvider.expenses.length;

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
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF373455)),
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
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              '$totalExpenses €',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '${t(context)!.totalFor} $usersCount ${t(context)!.persons}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    TabBar(
                      dividerColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      indicatorColor: Theme.of(context).colorScheme.secondary,
                      labelColor: Theme.of(context).colorScheme.secondary,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(fontSize: 12.0),
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.person),
                          text: '${t(context)!.persons} ($usersCount)',
                        ),
                        Tab(
                          icon: const Icon(Icons.attach_money),
                          text: '${t(context)!.expenses} ($expensesCount)',
                        ),
                        Tab(
                          icon: const Icon(Icons.balance),
                          text: t(context)!.balance,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    const Expanded(
                      child: TabBarView(
                        children: [
                          EventUsersTab(),
                          EventExpensesTab(),
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
              child: SizedBox(
                height: 60.0,
                child: Consumer<EventWebsocketProvider>(
                  builder: (context, eventProvider, child) {
                    final userTotalExpenses = eventProvider.userTotalExpenses;
                    final userAmountOwed = eventProvider.userAmountOwed;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(t(context)!.iSpent),
                            Text('$userTotalExpenses €'),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(t(context)!.owedToMe),
                            Text('$userAmountOwed €'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: AddButton(
            onPressed: () {
              if (isArchived) {
                Fluttertoast.showToast(
                  msg:
                      "La planète que vous essayez de consulter a été archivée et n'est plus en mission",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize:
                      Theme.of(context).textTheme.bodySmall?.fontSize ?? 16.0,
                );
              } else {
                _showAddOptions(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
