import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../home_page.dart'; // Import the HomePage file

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Task>> _events = {};

  final _taskController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadSavedEvents();
  }

  void _loadSavedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('events') ?? '{}';
    final Map<String, dynamic> decodedEvents = json.decode(eventsJson);

    setState(() {
      _events = Map.fromEntries(
        decodedEvents.entries.map(
          (entry) => MapEntry(
            DateTime.parse(entry.key),
            (entry.value as List).map((t) => Task.fromJson(t)).toList(),
          ),
        ),
      );
    });
  }

  void _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = json.encode(
      Map.fromEntries(
        _events.entries.map(
          (entry) => MapEntry(
            entry.key.toIso8601String(),
            entry.value.map((task) => task.toJson()).toList(),
          ),
        ),
      ),
    );
    await prefs.setString('events', eventsJson);
  }

  void _showAddTaskDialog(DateTime day) {
    _taskController.clear();
    _descriptionController.clear();
    _selectedTime = null;

    _showTaskDialog(day, isEditing: false);
  }

  void _showEditTaskDialog(DateTime day, Task task) {
    _taskController.text = task.title;
    _descriptionController.text = task.description;

    _selectedTime = task.time != null
        ? TimeOfDay.fromDateTime(DateFormat.jm().parse(task.time!))
        : null;

    _showTaskDialog(day, isEditing: true, existingTask: task);
  }

  void _showTaskDialog(DateTime day, {required bool isEditing, Task? existingTask}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: isEditing ? 'Edit Task Title' : 'Task Title',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: isEditing ? 'Edit Description' : 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedTime = pickedTime;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text(
                      _selectedTime == null
                          ? 'Select Time'
                          : 'Time: ${_selectedTime!.format(context)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  setState(() {
                    if (!isEditing) {
                      if (_events[day] == null) {
                        _events[day] = [];
                      }
                      _events[day]!.add(Task(
                        title: _taskController.text,
                        description: _descriptionController.text,
                        time: _selectedTime != null
                            ? _selectedTime!.format(context)
                            : null,
                        isDone: false,
                      ));
                    } else if (existingTask != null) {
                      existingTask.title = _taskController.text;
                      existingTask.description = _descriptionController.text;
                      existingTask.time = _selectedTime != null
                          ? _selectedTime!.format(context)
                          : null;
                    }
                  });
                  _saveEvents();
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                isEditing ? 'Update Task' : 'Add Task',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _deleteTask(DateTime day, Task task) {
    setState(() {
      _events[day]?.remove(task);
      if (_events[day]?.isEmpty ?? true) {
        _events.remove(day);
      }
      _saveEvents();
    });
  }

  Map<String, int> _calculateMonthlyTaskStats(DateTime month) {
    int totalTasks = 0;
    int completedTasks = 0;

    _events.forEach((date, tasks) {
      if (date.year == month.year && date.month == month.month) {
        totalTasks += tasks.length;
        completedTasks += tasks.where((task) => task.isDone).length;
      }
    });

    return {
      'total': totalTasks,
      'completed': completedTasks,
      'pending': totalTasks - completedTasks
    };
  }

  Widget _buildMonthlyTaskPieChart(DateTime month) {
    final stats = _calculateMonthlyTaskStats(month);

    if (stats['total'] == 0) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No tasks for this month',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Monthly Task Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: stats['completed']!.toDouble(),
                    color: Colors.green,
                    title: 'Completed\n${stats['completed']}',
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: stats['pending']!.toDouble(),
                    color: Colors.red,
                    title: 'Pending\n${stats['pending']}',
                    radius: 50,
                  ),
                ],
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Calendar',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255), // Change this to your desired heading color
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF1A1A2E),
        iconTheme: IconThemeData(
          color: const Color.fromARGB(255, 255, 255, 255), // Change this to your desired back button color
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HomePage(events: _events),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TableCalendar(
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.deepPurple[200],
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(color: Colors.white),
                        weekendTextStyle: TextStyle(color: Colors.white),
                        outsideTextStyle: TextStyle(color: Colors.white70),
                        markersAlignment: Alignment.bottomCenter,
                        markersMaxCount: 3,
                        markerDecoration: BoxDecoration(
                          color: Colors.deepPurple[200], // Event dot color
                          shape: BoxShape.circle,
                        ),
                      ),
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      eventLoader: (day) {
                        final tasksOnDay = _events[day] ?? [];
                        return tasksOnDay.isNotEmpty
                            ? [TaskEvent(date: day.toIso8601String(), taskCount: tasksOnDay.length)]
                            : [];
                      },
                    ),
                    if (_selectedDay != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tasks for ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: Colors.deepPurple,
                                size: 30,
                              ),
                              onPressed: () => _showAddTaskDialog(_selectedDay!),
                            ),
                          ],
                        ),
                      ),
                    _selectedDay != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _events[_selectedDay] != null
                                ? _events[_selectedDay]!.length
                                : 0,
                            itemBuilder: (context, index) {
                              final task = _events[_selectedDay]![index];
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                elevation: 3,
                                color: Colors.white.withOpacity(0.1),
                                child: ListTile(
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      decoration: task.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (task.description.isNotEmpty)
                                        Text(
                                          task.description,
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      if (task.time != null)
                                        Text(
                                          'Time: ${task.time}',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.white70),
                                        onPressed: () =>
                                            _showEditTaskDialog(_selectedDay!, task),
                                      ),
                                      Checkbox(
                                        value: task.isDone,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            task.isDone = value ?? false;
                                            _saveEvents();
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.white70),
                                        onPressed: () =>
                                            _deleteTask(_selectedDay!, task),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(),
                    _buildMonthlyTaskPieChart(_focusedDay),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskEvent {
  final String date;
  final int taskCount;

  TaskEvent({required this.date, required this.taskCount});
}

class Task {
  String title;
  String description;
  String? time;
  bool isDone;

  Task({
    required this.title,
    this.description = '',
    this.time,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'time': time,
        'isDone': isDone,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        description: json['description'] ?? '',
        time: json['time'],
        isDone: json['isDone'],
      );
}