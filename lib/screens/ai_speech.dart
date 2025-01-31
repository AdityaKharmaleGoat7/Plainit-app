import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class AISpeechPage extends StatefulWidget {
  @override
  _AISpeechPageState createState() => _AISpeechPageState();
}

class _AISpeechPageState extends State<AISpeechPage> {
  final _formKey = GlobalKey<FormState>();

  // Form input controllers
  final _topicController = TextEditingController();
  final _lengthController = TextEditingController();

  // Dropdown values
  String _selectedType = 'Speech';
  String _selectedTone = 'Professional';
  String _selectedAudience = 'Public';

  // Cohere API details
  final String cohereApiKey = 'r9uX1zwVave9HWB9FoY4AITKVd12BefKQ3hVWfw5'; // Replace with your actual key
  final String cohereEndpoint = 'https://api.cohere.ai/v1/generate';

  // List of options for dropdowns
  final List<String> _typeOptions = ['Speech', 'Lecture'];
  final List<String> _toneOptions = ['Professional', 'Conversational', 'Inspirational', 'Academic'];
  final List<String> _audienceOptions = ['Public', 'Private'];

  // List to store saved speeches
  List<Map<String, String>> _savedSpeeches = [];

  // SharedPreferences instance
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadSavedSpeeches(); // Load saved speeches when the page initializes
  }

  // Load saved speeches from SharedPreferences
  Future<void> _loadSavedSpeeches() async {
    _prefs = await SharedPreferences.getInstance();
    final savedSpeechesJson = _prefs.getStringList('savedSpeeches') ?? [];
    setState(() {
      _savedSpeeches = savedSpeechesJson.map((json) => Map<String, String>.from(jsonDecode(json))).toList();
    });
  }

  // Save speeches to SharedPreferences
  Future<void> _saveSpeeches() async {
    final savedSpeechesJson = _savedSpeeches.map((speech) => jsonEncode(speech)).toList();
    await _prefs.setStringList('savedSpeeches', savedSpeechesJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Speech Generator'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedSpeechesPage(
                    savedSpeeches: _savedSpeeches,
                    onDelete: _deleteSpeech,
                    onClearAll: _clearAllSpeeches,
                  ),
                ),
              );
            },
            tooltip: 'View Saved Speeches',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _topicController,
                        decoration: InputDecoration(
                          labelText: 'Topic',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a topic';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _lengthController,
                        decoration: InputDecoration(
                          labelText: 'Number of Words',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of words';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: _typeOptions.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedType = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedTone,
                        items: _toneOptions.map((String tone) {
                          return DropdownMenuItem<String>(
                            value: tone,
                            child: Text(tone),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedTone = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Tone',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedAudience,
                        items: _audienceOptions.map((String audience) {
                          return DropdownMenuItem<String>(
                            value: audience,
                            child: Text(audience),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedAudience = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Audience',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateSpeech,
                child: Text('Generate Speech'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateSpeech() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        // Construct detailed prompt
        String prompt = '''
Write a $_selectedTone $_selectedType for a $_selectedAudience audience on the topic "${_topicController.text}".
        ''';

        // Prepare payload for Cohere API
        int tokenLength = (int.tryParse(_lengthController.text) ?? 200);
        final payload = {
          "model": "command-xlarge",
          "prompt": prompt,
          "max_tokens": tokenLength,
          "temperature": 0.7,
          "k": 0,
          "p": 0.75,
          "frequency_penalty": 0.5,
          "presence_penalty": 0.5
        };

        // Make API request
        final response = await http.post(
          Uri.parse(cohereEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $cohereApiKey',
          },
          body: jsonEncode(payload),
        );

        // Close loading dialog
        Navigator.of(context).pop();

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          if (responseBody['generations'] != null &&
              responseBody['generations'].isNotEmpty) {
            final generatedSpeech = responseBody['generations'][0]['text'];

            // Navigate to result page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpeechResultPage(
                  speech: generatedSpeech,
                  topic: _topicController.text,
                  type: _selectedType,
                  tone: _selectedTone,
                  audience: _selectedAudience,
                  onSave: () async {
                    // Save the speech to the list
                    setState(() {
                      _savedSpeeches.add({
                        'topic': _topicController.text,
                        'speech': generatedSpeech,
                        'type': _selectedType,
                        'tone': _selectedTone,
                        'audience': _selectedAudience,
                      });
                    });
                    await _saveSpeeches(); // Save to SharedPreferences
                  },
                ),
              ),
            );
          } else {
            _showErrorSnackbar('No speech was generated. Try again.');
          }
        } else {
          _showErrorSnackbar('Failed to generate speech: ${response.statusCode}');
        }
      } catch (e) {
        Navigator.of(context).pop();
        _showErrorSnackbar('Error: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Delete a speech
  Future<void> _deleteSpeech(int index) async {
    setState(() {
      _savedSpeeches.removeAt(index);
    });
    await _saveSpeeches(); // Update SharedPreferences
  }

  // Clear all speeches
  Future<void> _clearAllSpeeches() async {
    setState(() {
      _savedSpeeches.clear();
    });
    await _saveSpeeches(); // Update SharedPreferences
  }

  @override
  void dispose() {
    _topicController.dispose();
    _lengthController.dispose();
    super.dispose();
  }
}

class SpeechResultPage extends StatelessWidget {
  final String speech;
  final String topic;
  final String type;
  final String tone;
  final String audience;
  final VoidCallback onSave;

  const SpeechResultPage({
    Key? key,
    required this.speech,
    required this.topic,
    required this.type,
    required this.tone,
    required this.audience,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated $type'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topic: $topic',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Type: $type | Tone: $tone | Audience: $audience',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  speech,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onSave();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        child: Icon(Icons.save),
        tooltip: 'Save Speech',
      ),
    );
  }
}

class SavedSpeechesPage extends StatelessWidget {
  final List<Map<String, String>> savedSpeeches;
  final Function(int) onDelete;
  final VoidCallback onClearAll;

  const SavedSpeechesPage({
    Key? key,
    required this.savedSpeeches,
    required this.onDelete,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Speeches'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (savedSpeeches.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: onClearAll,
              tooltip: 'Clear All Speeches',
            ),
        ],
      ),
      body: savedSpeeches.isEmpty
          ? Center(
              child: Text(
                'No saved speeches',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: savedSpeeches.length,
              itemBuilder: (context, index) {
                final speech = savedSpeeches[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(speech['topic'] ?? 'No Topic'),
                    subtitle: Text(
                      '${speech['type'] ?? 'No Type'} | ${speech['tone'] ?? 'No Tone'} | ${speech['audience'] ?? 'No Audience'}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(index),
                      tooltip: 'Delete Speech',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpeechResultPage(
                            speech: speech['speech'] ?? '',
                            topic: speech['topic'] ?? '',
                            type: speech['type'] ?? '',
                            tone: speech['tone'] ?? '',
                            audience: speech['audience'] ?? '',
                            onSave: () {}, // No need to save again
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}