import 'package:flutter/material.dart';
import 'package:nsm/services/event_websocket_service.dart';
import 'package:provider/provider.dart';

class EventUsersTab extends StatelessWidget {
  const EventUsersTab({super.key});

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
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: index == users.length - 1
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey),
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatar.url),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(user.username,
                          style: const TextStyle(color: Colors.white)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${user.totalExpenses.toStringAsFixed(2)} €',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white),
                        ),
                        Text(
                          '${user.expenseCount} dépenses',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
