import 'package:flutter/material.dart';
import '../google_meet_service.dart';

class Meeting {
  final String title;
  final DateTime dateTime;
  final String description;
  final bool isOnline;
  final String? meetingLink;
  final String? meetingPlatform;
  final String? meetingId;
  final String? passcode;

  Meeting({
    required this.title,
    required this.dateTime,
    required this.description,
    this.isOnline = false,
    this.meetingLink,
    this.meetingPlatform,
    this.meetingId,
    this.passcode,
  });
}

class ScheduleMeetingScreen extends StatefulWidget {
  @override
  _ScheduleMeetingScreenState createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  final List<Meeting> meetings = [];
  final GoogleMeetService _meetService = GoogleMeetService();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _meetingIdController = TextEditingController();
  final _passcodeController = TextEditingController();

  // State variables
  DateTime? _selectedDateTime;
  String _selectedPlatform = 'Google Meet'; // Changed default to Google Meet
  bool _isOnlineMeeting = false;
  bool _isCreatingMeeting = false;

  // List of meeting platforms
  final List<String> _platforms = ['Google Meet', 'Zoom', 'Microsoft Teams', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingLinkController.dispose();
    _meetingIdController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  void _saveMeeting(
    String title,
    DateTime dateTime,
    String description,
    bool isOnline,
    String? meetingLink,
    String? platform,
    String? meetingId,
    String? passcode,
  ) {
    setState(() {
      meetings.add(Meeting(
        title: title,
        dateTime: dateTime,
        description: description,
        isOnline: isOnline,
        meetingLink: meetingLink,
        meetingPlatform: platform,
        meetingId: meetingId,
        passcode: passcode,
      ));
    });

    // Clear input fields after saving
    _titleController.clear();
    _descriptionController.clear();
    _meetingLinkController.clear();
    _meetingIdController.clear();
    _passcodeController.clear();
    _selectedDateTime = null;
    setState(() {
      _isOnlineMeeting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Meeting saved successfully!")),
    );
  }

  Future<void> _createGoogleMeetLink() async {
    if (_titleController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in title and select date time first!")),
      );
      return;
    }

    setState(() {
      _isCreatingMeeting = true;
    });

    try {
      final meetLink = await _meetService.createMeetingLink(
        _titleController.text,
        _selectedDateTime!,
        _descriptionController.text,
      );

      if (meetLink != null) {
        setState(() {
          _meetingLinkController.text = meetLink;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Meeting link created successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create meeting link")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isCreatingMeeting = false;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Widget _buildOnlineMeetingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text('Online Meeting'),
          value: _isOnlineMeeting,
          onChanged: (bool value) {
            setState(() {
              _isOnlineMeeting = value;
            });
          },
        ),
        if (_isOnlineMeeting) ...[
          DropdownButtonFormField<String>(
            value: _selectedPlatform,
            decoration: InputDecoration(labelText: 'Platform'),
            items: _platforms.map((String platform) {
              return DropdownMenuItem(
                value: platform,
                child: Text(platform),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedPlatform = newValue!;
                // Clear meeting link when platform changes
                _meetingLinkController.clear();
              });
            },
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _meetingLinkController,
                  decoration: InputDecoration(labelText: 'Meeting Link'),
                ),
              ),
              if (_selectedPlatform == 'Google Meet') ...[
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isCreatingMeeting ? null : _createGoogleMeetLink,
                  child: _isCreatingMeeting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Create Link'),
                ),
              ],
            ],
          ),
          if (_selectedPlatform != 'Google Meet') ...[
            TextField(
              controller: _meetingIdController,
              decoration: InputDecoration(labelText: 'Meeting ID (Optional)'),
            ),
            TextField(
              controller: _passcodeController,
              decoration: InputDecoration(labelText: 'Passcode (Optional)'),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildMeetingListTile(Meeting meeting) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(meeting.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${meeting.dateTime.toLocal()}".split(' ')[0] +
                  ' ' +
                  TimeOfDay.fromDateTime(meeting.dateTime).format(context),
            ),
            Text(meeting.description),
            if (meeting.isOnline) ...[
              SizedBox(height: 8),
              Text('Platform: ${meeting.meetingPlatform}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (meeting.meetingLink != null && meeting.meetingLink!.isNotEmpty)
                SelectableText('Link: ${meeting.meetingLink}',
                    style: TextStyle(color: Colors.blue)),
              if (meeting.meetingId != null && meeting.meetingId!.isNotEmpty)
                SelectableText('Meeting ID: ${meeting.meetingId}'),
              if (meeting.passcode != null && meeting.passcode!.isNotEmpty)
                SelectableText('Passcode: ${meeting.passcode}'),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule a Meeting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Meeting Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Meeting Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickDateTime,
                  icon: Icon(Icons.calendar_today),
                  label: Text('Pick Date & Time'),
                ),
                SizedBox(width: 16),
                if (_selectedDateTime != null)
                  Expanded(
                    child: Text(
                      "${_selectedDateTime!.toLocal()}".split(' ')[0] +
                          ' ' +
                          TimeOfDay.fromDateTime(_selectedDateTime!).format(context),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            _buildOnlineMeetingFields(),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty &&
                      _selectedDateTime != null &&
                      _descriptionController.text.isNotEmpty) {
                    _saveMeeting(
                      _titleController.text,
                      _selectedDateTime!,
                      _descriptionController.text,
                      _isOnlineMeeting,
                      _isOnlineMeeting ? _meetingLinkController.text : null,
                      _isOnlineMeeting ? _selectedPlatform : null,
                      _isOnlineMeeting ? _meetingIdController.text : null,
                      _isOnlineMeeting ? _passcodeController.text : null,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill in all required fields!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Save Meeting', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Scheduled Meetings:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return _buildMeetingListTile(meeting);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}