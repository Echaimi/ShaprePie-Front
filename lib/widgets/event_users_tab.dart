import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';

class EventUsersTab extends StatefulWidget {
  final int eventId;

  const EventUsersTab({required this.eventId, super.key});

  @override
  _EventUsersTabState createState() => _EventUsersTabState();
}

class _EventUsersTabState extends State<EventUsersTab> {
  late Future<List<User>> _usersFuture;
  late EventService _eventService;

  @override
  void initState() {
    super.initState();
    _eventService =
        EventService(Provider.of<ApiService>(context, listen: false));
    _usersFuture = _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    return await _eventService.getEventUsers(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text(user.email),
              );
            },
          );
        } else {
          return const Center(child: Text('No users available'));
        }
      },
    );
  }
}
