import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class VoiceAssistantScreen extends StatefulWidget {
  @override
  _VoiceAssistantScreenState createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  String _correctedText = '';
  List<String> _transcriptionHistory = [];
  List<Note> _savedNotes = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadSavedNotes();
  }

  void _loadSavedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('savedNotes') ?? [];
    setState(() {
      _savedNotes = notesJson.map((json) => Note.fromJson(jsonDecode(json))).toList();
    });
  }

  void _saveNote(String text) async {
    final note = Note(
      content: text,
      timestamp: DateTime.now(),
    );
    
    final prefs = await SharedPreferences.getInstance();
    _savedNotes.add(note);
    
    final notesJson = _savedNotes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('savedNotes', notesJson);

    setState(() {});
    
    // Show save confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Note saved successfully')),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            _correctGrammar(_text);
          }),
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 3),
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
        );
      }
    } else {
      setState(() {
        _isListening = false;
        if (_text.isNotEmpty) {
          _transcriptionHistory.add(_text);
        }
      });
      _speech.stop();
    }
  }

  Future<void> _correctGrammar(String text) async {
    final url = Uri.parse('https://api.languagetool.org/v2/check');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'text': text,
        'language': 'en-US',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);
      final List matches = result['matches'];

      String correctedText = text;
      for (var match in matches) {
        final offset = match['offset'];
        final length = match['length'];
        final replacement = match['replacements'][0]['value'];
        
        correctedText = correctedText.replaceRange(offset, offset + length, replacement);
      }

      setState(() {
        _correctedText = correctedText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Voice Assistant'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.mic), text: 'Transcribe'),
              Tab(icon: Icon(Icons.note), text: 'Notes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Transcription Tab
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)], // Similar to TranslatorScreen gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isListening ? Colors.red[100] : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            _text,
                            style: TextStyle(
                              fontSize: 20,
                              color: _isListening ? Colors.red : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Corrected Text:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _correctedText,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          onPressed: _listen,
                          backgroundColor: _isListening ? Colors.red : Colors.deepPurple,
                          child: Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            color: Colors.white,
                          ),
                          heroTag: 'listen',
                        ),
                        FloatingActionButton(
                          onPressed: () => _saveNote(_correctedText),
                          backgroundColor: Colors.green,
                          child: Icon(Icons.save, color: Colors.white),
                          heroTag: 'save',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Notes Tab
            Container(
              color: Colors.purple[50],
              child: _savedNotes.isEmpty
                  ? Center(
                      child: Text(
                        'No saved notes',
                        style: TextStyle(fontSize: 18, color: Colors.purple),
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
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(note.content),
                              subtitle: Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(note.timestamp),
                                style: TextStyle(color: Colors.grey),
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
  final DateTime timestamp;

  Note({required this.content, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  static Note fromJson(Map<String, dynamic> json) => Note(
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
