import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _headingController = TextEditingController();
  List<Note> _savedNotes = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadSavedNotes();
  }

  void _loadSavedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('savedNotes') ?? [];
    setState(() {
      _savedNotes = notesJson.map((json) => Note.fromJson(jsonDecode(json))).toList();
    });
  }

  void _saveNote() async {
    final text = _controller.text.trim();
    final heading = _headingController.text.trim();

    if (text.isEmpty) return;

    final note = Note(
      content: text,
      heading: heading.isEmpty ? null : heading,
      timestamp: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();

    if (_editingIndex == null) {
      _savedNotes.add(note);
    } else {
      _savedNotes[_editingIndex!] = note;
      _editingIndex = null;
    }

    final notesJson = _savedNotes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('savedNotes', notesJson);

    _controller.clear();
    _headingController.clear();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editingIndex == null ? 'Note saved successfully' : 'Note updated successfully'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _editNote(int index) {
    final note = _savedNotes[index];
    _headingController.text = note.heading ?? '';
    _controller.text = note.content;
    setState(() {
      _editingIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF1A1A2E),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading TextField
            TextField(
              controller: _headingController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter heading (optional)',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20),
            // Note TextField
            TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter your note',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            // Save/Update Button
            ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                _editingIndex == null ? 'Save Note' : 'Update Note',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Saved Notes:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            // List of Saved Notes
            Expanded(
              child: _savedNotes.isEmpty
                  ? Center(
                      child: Text(
                        'No saved notes',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _savedNotes.length,
                      itemBuilder: (context, index) {
                        final note = _savedNotes[_savedNotes.length - 1 - index];
                        return Dismissible(
                          key: Key(note.timestamp.toString()),
                          background: Container(color: Colors.red),
                          onDismissed: (direction) async {
                            final prefs = await SharedPreferences.getInstance();
                            _savedNotes.remove(note);
                            final notesJson = _savedNotes.map((n) => jsonEncode(n.toJson())).toList();
                            await prefs.setStringList('savedNotes', notesJson);
                            setState(() {});
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            color: Colors.white.withOpacity(0.1),
                            child: ListTile(
                              title: Text(
                                note.heading ?? 'No Heading',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.content,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    DateFormat('yyyy-MM-dd HH:mm').format(note.timestamp),
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.edit, color: Colors.white70),
                                onPressed: () => _editNote(_savedNotes.length - 1 - index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class Note {
  final String content;
  final String? heading;
  final DateTime timestamp;

  Note({required this.content, this.heading, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'content': content,
        'heading': heading,
        'timestamp': timestamp.toIso8601String(),
      };

  static Note fromJson(Map<String, dynamic> json) => Note(
        content: json['content'],
        heading: json['heading'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}