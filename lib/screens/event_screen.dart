import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../services/api_service.dart';
import '../services/event_service.dart';
import '../models/expense.dart';

class EventScreen extends StatelessWidget {
  final String eventId;

  const EventScreen({required this.eventId, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(
        EventService(ApiService()),
      )..fetchEvent(eventId),
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
        body: Consumer<EventProvider>(
          builder: (context, provider, child) {
            final event = provider.getEventById(eventId);

            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (event == null) {
              return const Center(child: Text('Event not found'));
            }

            return FutureBuilder<List<Expense>>(
              future: provider.eventService.getExpenses(eventId),
              builder: (context, expensesSnapshot) {
                if (expensesSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (expensesSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${expensesSnapshot.error}'));
                } else if (!expensesSnapshot.hasData) {
                  return const Center(child: Text('No expenses found'));
                }

                final expenses = expensesSnapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text(event.name,
                        style: const TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    Text(event.description),
                    const SizedBox(height: 8.0),
                    Text('Author: ${event.author.name}'),
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
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    ...expenses.map((expense) {
                      return ListTile(
                        title: Text(expense.title),
                        subtitle: Text('Amount: ${expense.amount} €'),
                      );
                    }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
