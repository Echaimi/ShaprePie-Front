import 'package:flutter/material.dart';
import 'package:spaceshare/services/event_service.dart';
import 'package:spaceshare/models/event.dart';
import 'package:go_router/go_router.dart';

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
          title: Text('Confirm $action'),
          content: Text('Are you sure you want to $action this event?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text(action),
              onPressed: () async {
                try {
                  if (action == 'delete') {
                    await widget.eventService.deleteEvent(eventId);
                  } else if (action == 'archive') {
                    await widget.eventService
                        .updateEventState(eventId, 'archived');
                  }
                  setState(() {
                    eventsFuture = widget.eventService.getEvents();
                  });
                  context.pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to $action event: $e')),
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
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Manage Events', style: TextStyle(color: Colors.black)),
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final events = snapshot.data!;
            _sortEvents(events);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.grey[50],
                  dividerColor: Colors.black,
                  textTheme: const TextTheme(
                    bodyMedium: TextStyle(color: Colors.black),
                  ),
                ),
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
                              _rowsPerPage = value ??
                                  PaginatedDataTable.defaultRowsPerPage;
                            });
                          },
                          sortColumnIndex: 4,
                          sortAscending: _isSortedAscending,
                          columns: [
                            const DataColumn(
                              label: Text('ID',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            const DataColumn(
                              label: Text('Name',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            const DataColumn(
                              label: Text('Category',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            const DataColumn(
                              label: Text('Users',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            DataColumn(
                              label: const InkWell(
                                child: Row(
                                  children: [
                                    Text('State',
                                        style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ),
                              onSort: (int columnIndex, bool ascending) {
                                setState(() {
                                  _isSortedAscending = !_isSortedAscending;
                                });
                              },
                            ),
                            const DataColumn(
                              label: Text('Actions',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                          source:
                              _EventDataSource(events, _showConfirmationDialog),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _EventDataSource extends DataTableSource {
  final List<Event> events;
  final Future<void> Function(int eventId, String action)
      showConfirmationDialog;

  _EventDataSource(this.events, this.showConfirmationDialog);

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
                onPressed: () => showConfirmationDialog(event.id, 'archive'),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: () => showConfirmationDialog(event.id, 'delete'),
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
