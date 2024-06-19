import 'package:flutter/material.dart';
import 'package:nsm/services/event_websocket_service.dart';
import 'package:provider/provider.dart';

class EventUsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EventWebsocketProvider>(
      builder: (context, eventProvider, child) {
        final users = eventProvider.users;
        if (users.isEmpty) {
          return const Center(child: Text('No users available'));
        }
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
      },
    );
  }
}
