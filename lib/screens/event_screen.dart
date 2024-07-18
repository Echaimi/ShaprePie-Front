// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, empty_catches

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spaceshare/providers/auth_provider.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:spaceshare/services/event_service.dart';
import 'package:spaceshare/widgets/add_button.dart';
import 'package:spaceshare/widgets/bottom_modal.dart';
import 'package:spaceshare/widgets/event_balances_tab.dart';
import 'package:spaceshare/widgets/event_expenses_tab.dart';
import 'package:spaceshare/widgets/event_invitation_modal.dart';
import 'package:spaceshare/widgets/event_users_tab.dart';
import 'package:spaceshare/widgets/update_event_modal_content.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class EventScreen extends StatefulWidget {
  final int eventId;
  final EventService eventService;

  const EventScreen({
    required this.eventId,
    required this.eventService,
    super.key,
  });

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
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

  Future<void> _deleteEvent(
      BuildContext context, EventWebsocketProvider eventProvider) async {
    if (eventProvider.event != null) {
      await widget.eventService.deleteEvent(eventProvider.event!.id);
      context.go('/');
    }
  }

  Future<void> _updateEventState(
      EventWebsocketProvider eventProvider, int eventId, String state) async {
    try {
      await widget.eventService.updateEventState(eventId, state);
      setState(() {
        eventProvider.event!.updateState(state);
      });
      context.pop();
    } catch (e) {}
  }

  void _archiveEvent(
      BuildContext context, EventWebsocketProvider eventProvider) {
    if (eventProvider.event != null) {
      final newState =
          eventProvider.event!.state == 'active' ? 'archived' : 'active';
      _updateEventState(eventProvider, eventProvider.event!.id, newState);
    }
  }

  void _showAddOptions(
      BuildContext context, EventWebsocketProvider eventProvider) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              context.pop();
              context.push('/events/${widget.eventId}/expenses/create');
            },
            child: Text(t(context)!.addExpense),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              context.pop();
              context.push('/events/${widget.eventId}/refunds/create');
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
    final eventProvider = Provider.of<EventWebsocketProvider>(context);
    final isArchived = eventProvider.event?.state == 'archived';
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: () {
              context.go('/');
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.share_rounded, color: theme.colorScheme.primary),
              onPressed: () {
                final eventCode = eventProvider.event?.code;

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
            if (eventProvider.event?.author.id == authProvider.user!.id) ...[
              IconButton(
                icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                onPressed: () {
                  if (isArchived == true) {
                    Fluttertoast.showToast(
                      msg: t(context)!.archivedEventWarning,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 1,
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      textColor: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize:
                          Theme.of(context).textTheme.bodySmall?.fontSize ??
                              16.0,
                    );
                  } else {
                    _showModal(
                      context,
                      UpdateEventModalContent(
                        eventId: eventProvider.event!.id,
                        initialEventName: eventProvider.event!.name,
                        initialDescription:
                            eventProvider.event!.description ?? '',
                        initialCategoryId: eventProvider.event!.category.id,
                        eventProvider: eventProvider,
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: theme.colorScheme.primary),
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      actions: <CupertinoActionSheetAction>[
                        CupertinoActionSheetAction(
                          onPressed: () {
                            _deleteEvent(context, eventProvider);
                            context.pop();
                          },
                          child: Text(t(context)!.deleteEvent),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            _archiveEvent(context, eventProvider);
                            context.pop();
                          },
                          child: Text(
                            eventProvider.event!.state == 'active'
                                ? t(context)!.archiveEvent
                                : t(context)!.activateEvent,
                          ),
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
            final userTotalExpenses = eventProvider.userTotalExpenses;
            final userAmountOwed = eventProvider.userAmountOwed;
            final usersCount = users.length;
            final expensesCount =
                eventProvider.expenses.length + eventProvider.refunds.length;
            final userBalance = eventProvider.userBalance;
            final userBalanceIsPositive = (userBalance?.amount ?? 0) >= 0;

            if (event == null) {
              return Skeletonizer(
                enabled: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 200,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Container(
                                width: 150,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 70,
                              height: 50,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 50,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 50,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          width: double.infinity,
                          height: 2,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24.0),
                      Expanded(
                        child: Column(
                          children: List.generate(
                            8,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme
                                                  .secondaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                          const SizedBox(width: 16.0),
                                          Container(
                                            width: 100,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme
                                                  .secondaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 50,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme.secondaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),
                                  Container(
                                    width: double.infinity,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color:
                                          theme.colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      event.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: theme.colorScheme.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.9),
                          offset: const Offset(6.0, 6.0),
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text('${totalExpenses.toStringAsFixed(2)} €',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.primaryColor,
                              )),
                          Text(
                            '${t(context)!.totalFor} $usersCount ${t(context)!.persons}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Text(
                            '${t(context)!.iSpent}: ',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            '${userTotalExpenses.toStringAsFixed(2)} €',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ]),
                        const SizedBox(width: 32.0),
                        Row(
                          children: [
                            Text(
                              '${t(context)!.owedToMe}: ',
                              style: theme.textTheme.bodyLarge,
                            ),
                            Text(
                              '${userBalanceIsPositive ? userAmountOwed?.toStringAsFixed(2) : 0} €',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: userBalanceIsPositive
                                    ? const Color(0xFF3E908E)
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  TabBar(
                    dividerColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.primary,
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: AddButton(
          onPressed: () {
            if (isArchived == true) {
              Fluttertoast.showToast(
                msg: t(context)!.archivedEventWarning,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                textColor: Theme.of(context).textTheme.bodySmall?.color,
                fontSize:
                    Theme.of(context).textTheme.bodySmall?.fontSize ?? 16.0,
              );
            } else {
              _showAddOptions(context, eventProvider);
            }
          },
        ),
      ),
    );
  }
}
