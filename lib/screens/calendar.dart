import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleAPI;
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:intl/intl.dart';
import 'package:sponsite/screens/createEventFromCalendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';



class googleCalendar extends StatefulWidget {


  @override
  _googleCalendarState createState() => _googleCalendarState();
}
  
class _googleCalendarState extends State<googleCalendar> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // clientId: '[YOUR_OAUTH_2_CLIENT_ID]',
    scopes: <String>[GoogleAPI.CalendarApi.calendarScope],
  );

  GoogleSignInAccount? _currentUser;
  List<GoogleAPI.Event>? _appointments;
  String userEmail = '';
  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        userEmail = _currentUser!.email;
      });
      if (_currentUser != null) {
        // Don't fetch events here; it will be done in the FutureBuilder
      } 
    });
    _googleSignIn.signInSilently();
  }

  Future<List<GoogleAPI.Event>> getGoogleEventsData() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    final GoogleAPIClient httpClient =
        GoogleAPIClient(await googleUser!.authHeaders);

    final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
    String calendarID= '';

    if (userEmail == "leena252002@gmail.com"){
      calendarID= "lfra6b41b44lia16ug024ifpgk@group.calendar.google.com";
  }

    if (userEmail == "leena1234567891011@gmail.com"){
       calendarID= "2a70b27939c31f657d4a1675e5ff1db641018231e63961750309ac705496fd1a@group.calendar.google.com";
    }

   
    final GoogleAPI.Events calEvents = await calendarApi.events.list(
      calendarID  ,
    );
  

    final List<GoogleAPI.Event> appointments = <GoogleAPI.Event>[]; 
    if (calEvents.items != null) {
      for (int i = 0; i < calEvents.items!.length; i++) {
        final GoogleAPI.Event event = calEvents.items![i];
        if (event.start == null) {
          continue;
        }
        appointments.add(event);
      }
    }
       setState(() {  
        _appointments = appointments;
      });


    return appointments;
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(  
        preferredSize: const Size.fromHeight(100.0),  // Set the desired height   
        child: Container(
          height: 95,  
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 51, 45, 81),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),  
              bottomRight: Radius.circular(20),
            ),
          ),    
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
          child: Row( 
          children: [ 
            IconButton( 
              icon: Icon(Icons.arrow_back),
              alignment: Alignment.topLeft,
              color: Colors.white,
              iconSize:30,  
              onPressed: () {
                Navigator.of(context).pop();
              },  
            ),   
             SizedBox(width: 160) ,
            Center(       
                  child:  
                 Text( 
                "Google Calendar Events",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 30,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
         ),
         ],
         ),
          ),  
        ),      
      body: FutureBuilder<List<GoogleAPI.Event>>(
        future: getGoogleEventsData(),
        builder: (BuildContext context, AsyncSnapshot<List<GoogleAPI.Event>> snapshot) {
          return Stack(
            children: [
              SfCalendar( 
                view: CalendarView.month,
                initialDisplayDate: DateTime(2023, 10, 15, 9, 0, 0),
                selectionDecoration: BoxDecoration( 
                            border: Border.all(color: Color.fromARGB(255, 91, 79, 158), width: 1),    
                            borderRadius: 
                                const BorderRadius.all(Radius.circular(4)),
                            shape: BoxShape.rectangle,
                          ),  
                dataSource: GoogleDataSource(events:  _appointments ?? []),
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                       showAgenda: true,      
                            agendaViewHeight: 180,  
                            monthCellStyle: MonthCellStyle(
                            ), 
                             agendaItemHeight: 40,      
                ),        
                 showNavigationArrow: true,
                          todayHighlightColor: Color.fromARGB(255, 51, 45, 81), 
                          appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
    final GoogleAPI.Event event = details.appointments.first;
    final Color eventColor = Color.fromARGB(255, 91, 79, 158) ;   
    final double borderRadius = 12.0; 
    return InkWell(
                    onTap: () {
                      // Handle the appointment click here
                      _showEventDetails(event); 
                    },

                    child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container( 
          color: eventColor,    
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
            child: Text(  
              event.summary ?? 'No title',
              style: TextStyle(fontSize: 13, color: Colors.white),
              maxLines: 4,  
              // overflow: TextOverflow.ellipsis,
            ),  

        ),
                  ),
                      ),    
              );
        }),
              if (!snapshot.hasData)
                const Center(
                  child: CircularProgressIndicator(),
                ),
             Align(
  alignment: Alignment.bottomRight,
  child: Padding(
    padding: EdgeInsets.fromLTRB(0, 20, 20, 40),
    child: InkWell(
      onTap: () { 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => createEventFromCalendar(),
          ),
        );
      },  
      child: Container( 
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 51, 45, 81), 
        ),
        child: Icon(
          Icons.add,
          color:Colors.white,
          size: 60,  
        ),
      ),
    ),
  ),
),

            ],
          );
        },
      ),
    );
  }
bool isDateSelected = false;


void _showEventDetails(GoogleAPI.Event event) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Event Details', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Title:', event.summary ?? 'No title'),
            _buildDetailRow('Description:', event.description ?? 'No description'),
            _buildDetailRow('Start Date and Time:', formatDateAndTime(event.start)),
            _buildDetailRow('End Date and Time:', formatDateAndTime(event.end)),
            _buildGuestsList('Guests:', event.attendees),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },  
  );

}
Widget _buildDetailRow(String label, String value) {
   if (value == null || value.isEmpty) {
    return SizedBox.shrink(); // Return an empty SizedBox if value is null or empty
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    ),
  );
}


Widget _buildGuestsList(String label, List<GoogleAPI.EventAttendee>? attendees) {
  if (attendees == null || attendees.isEmpty) {
    return _buildDetailRow(label, 'No guests');
  }
  
  final guestEmails = attendees.map((attendee) => attendee.email ?? 'No email').join(', ');

  return _buildDetailRow(label, guestEmails);

} 


  String formatDateAndTime(GoogleAPI.EventDateTime? eventDateTime) {
  if (eventDateTime == null || eventDateTime.dateTime == null) {
    return 'No date and time';
  }
  final DateTime dateTime = eventDateTime.dateTime!;
  final String formattedDate = DateFormat.yMMMd().add_jm().format(dateTime);
  return formattedDate;
}
@override
  void dispose() {
    if (_googleSignIn.currentUser != null) {
      _googleSignIn.disconnect();
      _googleSignIn.signOut();
    }

    super.dispose();
  } 
}

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<GoogleAPI.Event>? events}) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.start?.date ?? event.start!.dateTime!.toLocal();
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].start.date != null;
  }

  @override
  DateTime getEndTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.endTimeUnspecified == true
        ? (event.start?.date ?? event.start!.dateTime!.toLocal())
        : (event.end?.date != null
            ? event.end!.date!.add(const Duration(days: 1))
            : event.end!.dateTime!.toLocal());
  }

  @override
  String getLocation(int index) {
    return appointments![index].location ?? '';
  }

  @override
  String getNotes(int index) {
    return appointments![index].description ?? '';
  }

  @override
  String getSubject(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.summary == null || event.summary!.isEmpty
        ? 'No Title'
        : event.summary!;
  }
}

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url,
          headers: (headers != null ? (headers..addAll(_headers)) : headers));
} 
