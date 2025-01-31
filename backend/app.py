import io
import pyaudio
from speech_recognition import AudioData, Recognizer
import language_tool_python
import sqlite3
from flask import Flask, jsonify, request
from flask_cors import CORS
import threading
import time

app = Flask(__name__)
CORS(app)

# Global variables
grammar_tool = language_tool_python.LanguageTool('en-US')
conn = sqlite3.connect("transcriptions.db", check_same_thread=False)
cursor = conn.cursor()

# Create table if not exists
cursor.execute("""
    CREATE TABLE IF NOT EXISTS transcriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_text TEXT NOT NULL,
        corrected_text TEXT NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
""")
conn.commit()

# Existing utility functions from original script
def capture_audio_to_buffer(duration=5, rate=16000, chunk=1024):
    p = pyaudio.PyAudio()
    stream = p.open(format=pyaudio.paInt16, channels=1, rate=rate, input=True, frames_per_buffer=chunk)
    frames = []

    for _ in range(0, int(rate / chunk * duration)):
        data = stream.read(chunk, exception_on_overflow=False)
        frames.append(data)

    stream.stop_stream()
    stream.close()
    p.terminate()

    audio_buffer = io.BytesIO(b''.join(frames))
    audio_data = AudioData(audio_buffer.getvalue(), rate, p.get_sample_size(pyaudio.paInt16))
    return audio_data

def speech_to_text(audio_data):
    recognizer = Recognizer()
    try:
        result = recognizer.recognize_google(audio_data, language="en-US", show_all=True)
        if result:
            text = result['alternative'][0]['transcript']
            return text
        return ""
    except Exception:
        return ""

def correct_grammar(text):
    try:
        matches = grammar_tool.check(text)
        corrected_text = language_tool_python.utils.correct(text, matches)
        return corrected_text
    except Exception:
        return text

# Global listening state
is_listening = False
recognition_thread = None

def continuous_recognition():
    global is_listening
    while is_listening:
        try:
            audio_data = capture_audio_to_buffer()
            raw_text = speech_to_text(audio_data)

            if raw_text:  # Make sure there is something to insert
                corrected_text = correct_grammar(raw_text)
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO transcriptions (original_text, corrected_text)
                    VALUES (?, ?)
                """, (raw_text, corrected_text))
                conn.commit()
                print(f"Original: {raw_text}, Corrected: {corrected_text}")
            else:
                print("No text detected from audio.")  # Debugging output
        except Exception as e:
            print(f"Recognition error: {e}")
        
        time.sleep(0.1)


@app.route('/start', methods=['POST'])
def start_listening():
    global is_listening, recognition_thread
    if not is_listening:
        is_listening = True
        recognition_thread = threading.Thread(target=continuous_recognition)
        recognition_thread.start()
        return jsonify({"status": "Started"})
    return jsonify({"status": "Already running"})

@app.route('/stop', methods=['POST'])
def stop_listening():
    global is_listening, recognition_thread
    is_listening = False
    if recognition_thread:
        recognition_thread.join()
    return jsonify({"status": "Stopped"})

@app.route('/transcriptions', methods=['GET'])
def get_transcriptions():
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM transcriptions ORDER BY timestamp DESC LIMIT 10")
    transcriptions = cursor.fetchall()
    return jsonify([{
        'id': t[0],
        'original_text': t[1],
        'corrected_text': t[2],
        'timestamp': t[3]
    } for t in transcriptions])

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)