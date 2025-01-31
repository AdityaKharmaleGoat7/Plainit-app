# Meet

Meet is a Flutter application designed to help users schedule and manage meetings. The app integrates with Google Meet to create meeting links and provides various features such as note-taking, voice assistance, and more.

## Features

- **Schedule Meetings**: Create and manage meetings with Google Meet integration.
- **Voice Assistant**: Use voice commands to interact with the app.
- **Notes**: Save and manage notes.
- **AI Speech Generator**: Generate speeches using AI.
- **Calendar**: View and manage your schedule.
- **Network**: Manage network settings.
- **Settings**: Customize app settings.

## Project Structure

. ├── .dart_tool/ ├── .idea/ ├── android/ ├── assets/ ├── backend/ ├── build/ ├── ios/ ├── lib/ │ ├── main.dart │ ├── screens/ │ │ ├── notes_screen.dart │ │ ├── schedule_meeting_screen.dart │ │ └── ... │ ├── voice_assistant.dart │ └── ... ├── linux/ ├── macos/ ├── test/ ├── web/ ├── windows/ ├── .gitignore ├── .metadata ├── analysis_options.yaml ├── firebase.json ├── flutter_01.log ├── pubspec.lock ├── pubspec.yaml └── README.md


## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK: Included with Flutter
- Android Studio or Visual Studio Code: Recommended IDEs

### Installation

1. Clone the repository
   git clone https://github.com/yourusername/meet.git
   cd meet

2.Install dependencies:
   flutter pub get

3. Set up Firebase:

Follow the instructions to set up Firebase for your Flutter project: Firebase Setup
Update main.dart with your Firebase configuration.


Running the App

1.Run the app on an emulator or physical device:
flutter run

2. Building the App
Build the app for release:
flutter build apk

Usage
Schedule a Meeting
Navigate to the Schedule Meeting screen.
Fill in the meeting details such as title, date, and description.
Click on "Generate Meeting Link" to create a Google Meet link.
Voice Assistant
Navigate to the Voice Assistant screen.
Use the microphone button to start and stop listening.
Save notes using voice commands.
Notes
Navigate to the Notes screen.
Add, edit, and delete notes as needed.
Configuration
Firebase
Update the firebase.json file with your Firebase project configuration.

Assets
Add your assets to the assets directory and update the pubspec.yaml file accordingly.

Contributing
Fork the repository.
Create a new branch (git checkout -b feature-branch).
Make your changes.
Commit your changes (git commit -m 'Add some feature').
Push to the branch (git push origin feature-branch).
Open a pull request.
License
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments
Flutter
Firebase
Google MeeT

