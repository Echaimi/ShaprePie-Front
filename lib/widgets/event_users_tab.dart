import 'package:flutter/material.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class EventUsersTab extends StatelessWidget {
  const EventUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventWebsocketProvider>(
      builder: (context, eventProvider, child) {
        final users = eventProvider.users;
        final theme = Theme.of(context);
        if (users.isEmpty) {
          return Center(child: Text(t(context)!.noUsersAvailable));
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
                      : BorderSide(color: theme.colorScheme.secondaryContainer),
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
                        child: Text(
                      user.username,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${user.totalExpenses.toStringAsFixed(2)} €',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${user.expenseCount} ${t(context)!.expenses}',
                          style: Theme.of(context).textTheme.bodySmall,
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
