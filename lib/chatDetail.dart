import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'dart:math';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EventCreationScreen(),
    );
  }
}

class EventCreationScreen extends StatefulWidget {
  @override
  _EventCreationScreenState createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );
  calendar.CalendarApi? _calendarApi;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<TextEditingController> _guestControllers = [];
  TextEditingController _googleMeetLink = TextEditingController();
  String _defaultOrganizerEmail = '';
  bool includeGoogleMeet = false;

  @override
  void initState() {
    super.initState();
    _initializeCalendarApi();
  }

  void _addGuestField() {
    setState(() {
      _guestControllers.add(TextEditingController());
    });
  }
 void _addGoogleMeetLink(){
   setState(() {
      _googleMeetLink=TextEditingController();
    });
  }

  Future<void> _initializeCalendarApi() async {
    try {
      await _googleSignIn.signIn();

      final GoogleSignInAccount? googleSignInAccount = _googleSignIn.currentUser;

      if (googleSignInAccount == null) {
        // Handle the case where the user didn't sign in.
        return;
      }

      // Extract the user's email from the GoogleSignInAccount.
      final userEmail = googleSignInAccount.email;
      if (userEmail == null) {
        // Handle the case where the user's email is null.
        return;
      }

      // Set _defaultOrganizerEmail to the user's email.
      setState(() {
        _defaultOrganizerEmail = userEmail;
      });

      final googleSignInAuthentication = await googleSignInAccount.authentication;

      final accessToken = googleSignInAuthentication.accessToken;
      print(accessToken);
      if (accessToken == null) {
        // Handle the case where accessToken is null.
        return;
      }

      final auth.AuthClient client = await _createAuthClient(
         '12786188351-4u10hbgv85tuf2mcpuirbuh4fj745ut6.apps.googleusercontent.com', // Replace with your client ID from the Google Cloud Console.
        accessToken,
      );

      setState(() {
        _calendarApi = calendar.CalendarApi(client);
        print("success");
      });
    } catch (error) {
      print('Error initializing calendar API: $error');
    }
  }

  Future<auth.AuthClient> _createAuthClient(
    String clientId,
    String accessToken,
  ) async {
    final scopes = [calendar.CalendarApi.calendarScope];

    final credentials = auth.AccessCredentials(
      auth.AccessToken('Bearer', accessToken, DateTime.now().toUtc().add(Duration(hours: 1))),
      '',
      scopes,
    );

    final httpClient = http.Client();
    final authenticatedClient = auth.autoRefreshingClient(
      auth.ClientId(clientId, null),
      credentials,
      httpClient,
    );

    return authenticatedClient;
  }

  Future<void> _signInWithGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print('Error signing in with Google: $error');
    }
  }

  Future<void> _createEvent() async {
  try {
    if (_calendarApi == null) {
      // Handle the case where calendarApi is not initialized.
      return;
    }

    final event = calendar.Event()
      ..summary = _titleController.text
      ..description = _descriptionController.text
      ..start = calendar.EventDateTime(dateTime: _startDate.toUtc())
      ..end = calendar.EventDateTime(dateTime: _endDate.toUtc())
      ..organizer = calendar.EventOrganizer(email: _defaultOrganizerEmail)
      ..guestsCanSeeOtherGuests = true;

    final guests = _guestControllers.map((controller) => controller.text).toList();
    if (guests.isNotEmpty) {
      event.attendees = guests.map((email) => calendar.EventAttendee(email: email)).toList();
        if (_defaultOrganizerEmail != null) {
       event.attendees!.add(calendar.EventAttendee(email: _defaultOrganizerEmail));
}}

if(includeGoogleMeet){
event.description = '${_descriptionController.text} \nGoogleMeet Link: ${_googleMeetLink.text}';
}
else{
  event.description = _descriptionController.text;
}


     await _calendarApi!.events.insert(event, 'primary');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Event created in Google Calendar'),
    ));
  } catch (error) {
    print('Error creating event: $error');
  }
}





  Future<void> _selectStartDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );

      if (selectedTime != null) {
        setState(() {
          _startDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDate),
      );

      if (selectedTime != null) {
        setState(() {
          _endDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event in Google Calendar'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text('Sign in with Google'),
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Event Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Event Description'),
              ),
              Column(
                children: _guestControllers.map((controller) {
                  return TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: 'Guest Email'),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: _addGuestField,
                child: Text('Add Guest'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Show date and time pickers to set start and end dates/times.
                  _selectStartDate(context);
                },
                child: Text('Select Start Date & Time'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Show date and time pickers to set start and end dates/times.
                  _selectEndDate(context);
                },
                child: Text('Select End Date & Time'),
              ),
              CheckboxListTile(
                title: Text('Include Google Meet'),
                value: includeGoogleMeet,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      includeGoogleMeet = value;
                    });
                  }
                },
              ),
                if (includeGoogleMeet) // Conditional rendering of Google Meet link text field
                      TextField(
                        controller: _googleMeetLink,
                        decoration: InputDecoration(labelText: 'Google Meet Link'),
                      ),
              ElevatedButton(
                onPressed: () {
                  _createEvent(); // Call _createEvent when the button is pressed.
                },
                child: Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

