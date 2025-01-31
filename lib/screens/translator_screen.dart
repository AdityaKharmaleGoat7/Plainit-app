import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';

class TranslatorScreen extends StatefulWidget {
  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = 'Press the button and speak in Hindi';
  String _translatedText = '';
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
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
          onResult: (val) async {
            setState(() {
              _spokenText = val.recognizedWords;
            });
            // Translate the recognized text in real-time
            if (val.recognizedWords.isNotEmpty) {
              await _processText(val.recognizedWords);
            }
          },
          partialResults: true, // Enable partial results for real-time updates
          localeId: 'hi-IN', // Specify Hindi locale
        );
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop(); // Stop listening when the button is pressed again
    }
  }

  Future<void> _processText(String text) async {
    if (text.isEmpty) return;

    try {
      // Translation
      var translation = await translator.translate(text, from: 'hi', to: 'en');

      setState(() {
        _translatedText = translation.text;
      });
    } catch (e) {
      setState(() {
        _translatedText = 'Translation failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Speech Translator',
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
            SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isListening)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 4,
                    ),
                  FloatingActionButton(
                    onPressed: _listen,
                    backgroundColor:
                        _isListening ? Colors.red : Colors.deepPurple,
                    elevation: 8,
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Spoken Text (Hindi):',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _spokenText,
                  style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Translated Text (English):',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _translatedText.isEmpty
                      ? 'Translation will appear here'
                      : _translatedText,
                  style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '1. Press the mic button and speak in Hindi.\n'
                  '2. The speech will be recognized and displayed.\n'
                  '3. The translation in English will appear below.\n'
                  '4. Press the button again to stop listening.',
                  style: TextStyle(fontSize: 16, color: const Color.fromARGB(179, 0, 0, 0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}