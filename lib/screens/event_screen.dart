import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/expense_provider.dart';
import '../services/websocket_service.dart';
import '../services/expense_service.dart';
import 'package:go_router/go_router.dart';

class EventScreen extends StatelessWidget {
  final int eventId;

  const EventScreen({required this.eventId, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ExpenseProvider(
            expenseService: ExpenseService(WebSocketService(
                'ws://localhost:8080/api/v1/ws/events/$eventId')),
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Provider.of<EventProvider>(context, listen: false)
                    .deleteEvent(eventId);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Consumer2<EventProvider, ExpenseProvider>(
          builder: (context, eventProvider, expenseProvider, child) {
            final event = eventProvider.getEventById(eventId);

            if (eventProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (event == null) {
              return const Center(child: Text('Event not found'));
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(event.name,
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                Text(event.description),
                const SizedBox(height: 8.0),
                Text('Author: ${event.author.username}'),
                const SizedBox(height: 8.0),
                Text('Category: ${event.category.name}'),
                const SizedBox(height: 8.0),
                Image.network(event.image),
                const SizedBox(height: 8.0),
                Text('Goal: ${event.goal} €'),
                const SizedBox(height: 8.0),
                Text('Code: ${event.code}'),
                const SizedBox(height: 8.0),
                Text('State: ${event.state}'),
                const SizedBox(height: 16.0),
                const Text('Expenses:',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                if (expenseProvider.expenses.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  ...expenseProvider.expenses.map((expense) {
                    return ListTile(
                      title: Text(expense.title),
                      subtitle: Text('Amount: ${expense.amount} €'),
                    );
                  }),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex:
              0, // You can manage this state if you want to highlight the selected item
          onTap: (index) {
            if (index == 0) {
              context.go('/');
            } else if (index == 1) {
              context.go('/profile');
            }
          },
        ),
      ),
    );
  }
}
