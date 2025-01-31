import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GoogleMeetService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events'
    ],
  );

  AccessCredentials? _credentials;
  AutoRefreshingAuthClient? _client;

  Future<void> _authenticate() async {
    if (_client != null) return;

    print('Starting authentication...');
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) throw Exception('User not signed in');

    print('User signed in: ${account.email}');
    final GoogleSignInAuthentication googleAuth = await account.authentication;

    _credentials = AccessCredentials(
      AccessToken(
        'Bearer',
        googleAuth.accessToken!,
        DateTime.now().toUtc().add(Duration(seconds: 3600)),
      ),
      null,
      _googleSignIn.scopes,
    );

    final clientId = ClientId("YOUR_CLIENT_ID", "YOUR_CLIENT_SECRET");
    _client = await clientViaUserConsent(clientId, _googleSignIn.scopes, (url) {
      print('Please go to the following URL and grant access: $url');
    });

    print('Authentication complete.');
  }

  Future<String?> createMeetingLink(String title, DateTime startTime, String description) async {
    try {
      print('Authenticating user...');
      await _authenticate();

      if (_client == null) throw Exception('Client not initialized');

      print('Creating calendar event...');
      final calendar.CalendarApi calendarApi = calendar.CalendarApi(_client!);

      // Set event start and end times
      final eventStart = calendar.EventDateTime();
      eventStart.dateTime = startTime.toUtc();
      eventStart.timeZone = 'UTC';

      final eventEnd = calendar.EventDateTime();
      eventEnd.dateTime = startTime.add(Duration(hours: 1)).toUtc();
      eventEnd.timeZone = 'UTC';

      // Set up conference data for Google Meet
      final conferenceData = calendar.ConferenceData();
      final createRequest = calendar.CreateConferenceRequest();
      final solutionKey = calendar.ConferenceSolutionKey();
      solutionKey.type = 'hangoutsMeet';
      createRequest.requestId = "${DateTime.now().millisecondsSinceEpoch}";
      createRequest.conferenceSolutionKey = solutionKey;
      conferenceData.createRequest = createRequest;

      // Create the event
      final event = calendar.Event();
      event.summary = title;
      event.description = description;
      event.start = eventStart;
      event.end = eventEnd;
      event.conferenceData = conferenceData;

      // Insert the event with conference data
      print('Inserting event into calendar...');
      final calendar.Event createdEvent = await calendarApi.events.insert(
        event,
        'primary',
        conferenceDataVersion: 1,
      );

      print('Event created: ${createdEvent.id}');

      // Return the Google Meet link
      if (createdEvent.conferenceData?.entryPoints != null &&
          createdEvent.conferenceData!.entryPoints!.isNotEmpty) {
        final meetLink = createdEvent.conferenceData!.entryPoints!.first.uri;
        print('Google Meet link: $meetLink');
        return meetLink;
      }

      print('No Google Meet link found.');
      return null;
    } catch (e) {
      print('Error creating meeting: $e');
      return null;
    }
  }
}