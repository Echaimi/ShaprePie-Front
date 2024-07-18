// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:spaceshare/services/event_service.dart';
import 'package:spaceshare/models/event.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class EventsScreen extends StatefulWidget {
  final EventService eventService;

  const EventsScreen({super.key, required this.eventService});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<Event>> eventsFuture;
  bool _isSortedAscending = true;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    eventsFuture = widget.eventService.getEvents();
  }

  Future<void> _showConfirmationDialog(int eventId, String action) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${t(context)?.confirm} $action'),
          content: Text(
              '${t(context)?.confirmationQuestion} $action ${t(context)?.thisEvent}?'),
          actions: <Widget>[
            TextButton(
              child: Text(t(context)?.cancel ?? 'Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text(action),
              onPressed: () async {
                try {
                  if (action == t(context)?.delete) {
                    await widget.eventService.deleteEvent(eventId);
                  } else if (action == t(context)?.archive) {
                    await widget.eventService
                        .updateEventState(eventId, 'archived');
                  }
                  setState(() {
                    eventsFuture = widget.eventService.getEvents();
                  });
                  context.pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${t(context)?.failedTo} $action ${t(context)?.thisEvent}: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _sortEvents(List<Event> events) {
    events.sort((a, b) {
      int cmp = a.state.compareTo(b.state);
      return _isSortedAscending ? cmp : -cmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(t(context)?.manageEvents ?? 'Manage Events',
              style: const TextStyle(color: Colors.black)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Event>>(
        future: eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child:
                    Text('${t(context)?.error ?? 'Error'}: ${snapshot.error}'));
          } else {
            final events = snapshot.data!;
            _sortEvents(events);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: constraints.maxWidth),
                      child: PaginatedDataTable(
                        rowsPerPage: _rowsPerPage,
                        onRowsPerPageChanged: (int? value) {
                          setState(() {
                            _rowsPerPage =
                                value ?? PaginatedDataTable.defaultRowsPerPage;
                          });
                        },
                        sortColumnIndex: 4,
                        sortAscending: _isSortedAscending,
                        columns: [
                          DataColumn(
                            label: Text(t(context)?.id ?? 'ID',
                                style: const TextStyle(color: Colors.black)),
                          ),
                          DataColumn(
                            label: Text(t(context)?.name ?? 'Name',
                                style: const TextStyle(color: Colors.black)),
                          ),
                          DataColumn(
                            label: Text(t(context)?.category ?? 'Category',
                                style: const TextStyle(color: Colors.black)),
                          ),
                          DataColumn(
                            label: Text(t(context)?.users ?? 'Users',
                                style: const TextStyle(color: Colors.black)),
                          ),
                          DataColumn(
                            label: InkWell(
                              child: Row(
                                children: [
                                  Text(t(context)?.state ?? 'State',
                                      style:
                                          const TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                            onSort: (int columnIndex, bool ascending) {
                              setState(() {
                                _isSortedAscending = !_isSortedAscending;
                              });
                            },
                          ),
                          DataColumn(
                            label: Text(t(context)?.actions ?? 'Actions',
                                style: const TextStyle(color: Colors.black)),
                          ),
                        ],
                        source: _EventDataSource(
                            context, events, _showConfirmationDialog),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class _EventDataSource extends DataTableSource {
  final BuildContext context;
  final List<Event> events;
  final Future<void> Function(int eventId, String action)
      showConfirmationDialog;

  _EventDataSource(this.context, this.events, this.showConfirmationDialog);

  @override
  DataRow? getRow(int index) {
    if (index >= events.length) return null;
    final event = events[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(event.id.toString(),
            style: const TextStyle(color: Colors.black))),
        DataCell(Text(event.name, style: const TextStyle(color: Colors.black))),
        DataCell(Text(event.category.name,
            style: const TextStyle(color: Colors.black))),
        DataCell(Text(event.userCount?.toString() ?? '0',
            style: const TextStyle(color: Colors.black))),
        DataCell(
            Text(event.state, style: const TextStyle(color: Colors.black))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.archive, color: Colors.black),
                onPressed: () => showConfirmationDialog(
                    event.id, t(context)?.archive ?? 'archive'),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: () => showConfirmationDialog(
                    event.id, t(context)?.delete ?? 'delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => events.length;

  @override
  int get selectedRowCount => 0;
}
