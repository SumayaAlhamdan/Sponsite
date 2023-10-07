import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


class createEvent extends StatefulWidget {
  
  @override
  _createEventState createState() => _createEventState();
}

class _createEventState extends State<createEvent> {
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
  TextEditingController _startDatetimeController = TextEditingController();
  TextEditingController _endDatetimeController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TextEditingController _guestController = TextEditingController();
  TextEditingController _googleMeetLink = TextEditingController();
  String _defaultOrganizerEmail = '';
  bool includeGoogleMeet = false;
  List<String> _guestEmails = [];
  String? _errorMessage;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? errorMessage;
  @override
  void initState() {
    super.initState();
    _initializeCalendarApi();
  }

  void _addGuest(String email) {
  setState(() {
    _guestEmails.add(email);
    _guestController.clear();
  });
}
  void _removeGuest(String email) {
  setState(() {
    _guestEmails.remove(email);
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
      print(error);
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



   if (_guestEmails.isNotEmpty) {
      event.attendees = _guestEmails.map((email) {
        return calendar.EventAttendee(email: email);
      }).toList();
    }

        if (_defaultOrganizerEmail != null) {
          event.attendees ??= [];
          event.attendees!.add(calendar.EventAttendee(email: _defaultOrganizerEmail));
}

  
if(includeGoogleMeet){
event.description = '${_descriptionController.text} \nGoogleMeet Link: ${_googleMeetLink.text}';
}   
else{
  event.description = _descriptionController.text;
}
// event.sendNotifications = true; 

     await _calendarApi!.events.insert(event, 'lfra6b41b44lia16ug024ifpgk@group.calendar.google.com');

     _showSummaryDialog();
  } catch (error) {
      print(error);    // Show the error dialog for the specific error type
 setState(() {
    errorMessage = 'Invalid Date and Time';
  });
  }
  }


String _formatDateTime(DateTime dateTime) {
  // Format the DateTime in the desired format.
  final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  return formattedDate;
}

Future<void> _showSummaryDialog() async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      final bool isTitleEmpty = _titleController.text.isEmpty;
      final bool isDescriptionEmpty = _descriptionController.text.isEmpty;
      final bool isStartDateEmpty = _startDate == null;
      final bool isEndDateEmpty = _endDate == null;
      final bool isGuestsEmpty = _guestEmails.isEmpty;

      return AlertDialog(
        icon: Icon(
          Icons.check_circle_rounded,
          size: 80,
          color: const Color.fromARGB(255, 133, 201, 135),
        ),
        title: Text(
          'Event Created Successfully',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  Text(
                    'Title: ',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isTitleEmpty ? 'No title' : _titleController.text,
                    style: TextStyle(fontSize: 21),
                  ),
                ],
              ),    
              Row(  
                children: [
                  Text(
                    'Description: ',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),  
                  Text( 
                    isDescriptionEmpty ? 'No description' : truncateDescription("${_descriptionController.text}", 40),  
                    style: TextStyle(fontSize: 21), 
                  ),
                ],  
              ),
              Row(
                children: [
                  Text(
                    'Start Date and Time: ',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isStartDateEmpty ? 'No start date' : _formatDateTime(_startDate),
                    style: TextStyle(fontSize: 21),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'End Date and Time: ',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isEndDateEmpty ? 'No end date' : _formatDateTime(_endDate),
                    style: TextStyle(fontSize: 21),
                  ),
                ],
              ),
              if (includeGoogleMeet)
                Row(
                  children: [
                    Text(
                      'Google Meet Link: ',
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _googleMeetLink.text.isEmpty ? 'No Google Meet link' : _googleMeetLink.text,
                      style: TextStyle(fontSize: 21),
                    ),
                  ],
                ),
              SizedBox(height: 8),
              Text(
                'Guests:',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              if (isGuestsEmpty)
                Text(
                  'No guests',
                  style: TextStyle(fontSize: 21),
                ),
              if (!isGuestsEmpty)
                Column(
                  children: _guestEmails.map((email) {
                    return Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            email,
                            style: TextStyle(fontSize: 21),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
            ),
          ),
        ],
      );
    },
  );
}
String truncateDescription(String description, int maxLineLength) {
  if (description.length <= maxLineLength) {
    return description;
  } else {
    final List<String> words = description.split(' ');
    final List<String> lines = [];
    String currentLine = words[0];

    for (int i = 1; i < words.length; i++) {
      if ((currentLine + ' ' + words[i]).length <= maxLineLength) {
        currentLine += ' ' + words[i];
      } else {
        lines.add(currentLine);
        currentLine = words[i];
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    if (lines.length == 1) {
      // If there's only one line, return it as is
      return lines[0];
    } else {
      // If there are multiple lines, join them with line breaks
      return lines.join('\n');
    }
  }
}

  Future<void> _selectStartDate(BuildContext context) async {
     setState(() {
    errorMessage = null; // Clear the error message
  });
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
            _startDatetimeController.text =
                '${_startDate!.toLocal().toString().substring(0, 10)} , ${selectedTime!.format(context)}';

        });
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
 setState(() {
    errorMessage = null; // Clear the error message
  });
    
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
               _endDatetimeController.text =
                '${_endDate!.toLocal().toString().substring(0, 10)} , ${selectedTime!.format(context)}';

        });
      }
    }
  }

  bool _isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
  return emailRegex.hasMatch(email);
}

    Widget _buildChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _guestEmails.map((email) {
        return Chip(
          label: Text(email),
          deleteIcon: Icon(Icons.cancel),
          onDeleted: () {
            setState(() {
              _guestEmails.remove(email);
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
  decoration: const BoxDecoration(
    color: Color.fromARGB(255, 51, 45, 81),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  ),
  height: 85, 
  padding: const EdgeInsets.fromLTRB(16, 0, 0, 0), // Adjust the padding as needed
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        alignment: Alignment.topLeft,
        color: Colors.white,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      const SizedBox(width: 180),
      const Text(
        "Create Google Calendar Event",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
          color: Colors.white
        ),
        textAlign: TextAlign.center,
      ),// Adjust the spacing as needed
    ],
  ),
),
const SizedBox(height: 40), 
Container(  
  width: 200, // Set the width of the container
  height: 200, 
  child: Image.asset('assets/googleCalendar.png'),// Set the height of the container  
),        

              Container(
                 padding: const EdgeInsets.fromLTRB(35, 35, 35, 35),
                 child: Column(
                  children: [
                 SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _titleController,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Event Title',
                      prefixIcon: Icon(Icons.text_fields,
                          size: 24, color: Colors.black),
                    ),),),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _descriptionController,
                    maxLength: 100,
                    maxLines: 9,    
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(), 
                      labelText: 'Enter Event Description',
                      prefixIcon: Icon(Icons.text_fields,
                          size: 24, color: Colors.black), 
                    ),),),
                    if (errorMessage != null)
                       Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 330, 4),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
      
                 SizedBox(height:8),
              SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      controller: _startDatetimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Start Date and Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.calendar_month,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onTap: () {
                        _selectStartDate(context);
                      },
                    )),
                     SizedBox(height: 25),
              SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      controller: _endDatetimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select End Date and Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.calendar_month,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onTap: () {
                        _selectEndDate(context);
                      },
                    )),
                    SizedBox(height: 25),
                       if (_errorMessage != null) // Display the error message if it's not null
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 330, 4),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
      
Container(
  width: MediaQuery.of(context).size.width * 0.6,
  padding: EdgeInsets.all(8.0),
  decoration: BoxDecoration(
    border: Border.all(
      color: Colors.grey,
    ),
    borderRadius: BorderRadius.all(Radius.circular(5)),
  ),
  child: Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChips(),
        TextFormField(
          key: Key("guest_email_field"), // Add a unique key
          controller: _guestController,
           maxLength: 320,
          decoration: InputDecoration(
            hintText: 'Enter Guests Emails',
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.email,
              size: 24,
              color: Colors.black,
            ),
          ),
          onFieldSubmitted: (email) {
             if (email.isEmpty) {
                setState(() {
                  _errorMessage = null; // Clear the error message
                });
              }
            else if (_isValidEmail(email)) {
              _addGuest(email);
              setState(() {
                _errorMessage = null; // Clear the error message
              });
            } else {
              setState(() {
                _errorMessage = 'Invalid email format'; // Set the error message
              });
            }
          },
          onChanged: (email) {
            setState(() {
                 _errorMessage = null;

            });
            },
        ),
      ],
    ),
  ),
),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                          SizedBox(width: 120),
                          Checkbox(
                          value: includeGoogleMeet,
                          activeColor: Color.fromARGB(255, 51, 45, 81),
                          checkColor: Color.fromARGB(255, 255, 255, 255),
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                includeGoogleMeet = value;
                              });
                            }
                          },
                        ),
                        Text('Include Google Meet', style: TextStyle(fontSize:20)),
                      ],
                      ),

                if (includeGoogleMeet)
                    Column(
                       mainAxisAlignment: MainAxisAlignment.start,
                      children:[
                  SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _googleMeetLink,
                    maxLength: 70,  
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                      Icons.link,
                      size: 24,
                      color: Colors.black,
                    ),
                      labelText: 'Enter google meet link',
                    ),
                    ),
                    ),
                    Row(
                    children: [
                       SizedBox(width:450),
                        InkWell(
                        child: Text('Go To Google Meet', style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 24, 103, 221), decoration: TextDecoration.underline,)),
                        onTap: () => launch('https://meet.google.com/'),
                      ),
                    ],
                  ),

                    ],
                    ),
                    SizedBox(height: 25),
                  ElevatedButton(
                              onPressed: () {
                                _createEvent();
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                      const Color.fromARGB(255, 51, 45, 81)),
                                  //Color.fromARGB(255, 207, 186, 224),), // Background color
                                  textStyle: MaterialStateProperty.all<TextStyle>(
                                      const TextStyle(
                                          fontSize: 16)), // Text style
                                  padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                      const EdgeInsets.all(16)), // Padding
                                  elevation: MaterialStateProperty.all<double>(
                                      1), // Elevation
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30), // Border radius
                                      side: const BorderSide(
                                          color: Color.fromARGB(255, 255, 255,
                                              255)), // Border color
                                    ),
                                  ),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      const Size(200, 50))),
                              child: const Text(
                                'Create Event',style: TextStyle(color: Colors.white)
                              ),
                            ),
              ],
          ),
          ),
          ],
          ),
        ),  
    );
  }
}

