import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'screens/calendar_screen.dart'; // Import the file where Task is defined

class HomePage extends StatelessWidget {
  final Map<DateTime, List<Task>> events;

  HomePage({required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UpcomingTasks(events: events),
            // Add other widgets here if needed
          ],
        ),
      ),
    );
  }
}

class UpcomingTasks extends StatelessWidget {
  final Map<DateTime, List<Task>> events;

  UpcomingTasks({required this.events});

  @override
  Widget build(BuildContext context) {
    // Filter tasks that are due in the future
    final upcomingTasks = events.entries
        .where((entry) => entry.key.isAfter(DateTime.now()))
        .expand((entry) => entry.value)
        .toList();

    // Sort tasks by date
    upcomingTasks.sort((a, b) {
      final dateA = events.entries.firstWhere((entry) => entry.value.contains(a)).key;
      final dateB = events.entries.firstWhere((entry) => entry.value.contains(b)).key;
      return dateA.compareTo(dateB);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Upcoming Tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (upcomingTasks.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No upcoming tasks',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        if (upcomingTasks.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: upcomingTasks.length,
            itemBuilder: (context, index) {
              final task = upcomingTasks[index];
              final taskDate = events.entries
                  .firstWhere((entry) => entry.value.contains(task))
                  .key;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (task.description.isNotEmpty) Text(task.description),
                      if (task.time != null)
                        Text(
                          'Time: ${task.time}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(taskDate)}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Checkbox(
                    value: task.isDone,
                    onChanged: (bool? value) {
                      // Handle task completion
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}