import 'dart:convert';
import 'dart:ffi';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
class Event {
  final String EventId;
  final String sponseeId;
  final String EventName;
  final String EventType;
  final String location;
  final String imgURL;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final List<String> Category;
  final String notes;
  final String? benefits;
  final String  NumberOfAttendees ; 
  final String timeStamp;

  Event({
    required this.EventId,
    required this.sponseeId,
    required this.EventName,
    required this.EventType,
    required this.location,
    required this.imgURL,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.Category,
     required  this.notes,
    this.benefits,
    required this.NumberOfAttendees, 
    required this.timeStamp, 
  });
}
class Offer {
  final String EventId;
  final String sponseeId;
  final String sponsorId;
  final List<String> Category;
  final String notes;
  final String TimeStamp;

  Offer({
    required this.EventId,
    required this.sponseeId,
    required this.sponsorId,
    required this.Category,
    required this.notes,
    required this.TimeStamp, 
  });
}
class RecentEventsDetails extends StatelessWidget {
  final String? sponsorID;
  final String EventId;
  final String sponseeId;
  final String EventName;
  final String EventType;
  final String location;
  final String imgURL;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final List<String> Category;
  final String notes;
  final String? benefits;
  final String  NumberOfAttendees ; 
  final String timeStamp;


  const RecentEventsDetails({super.key,required this.sponsorID, required this.EventId, required this.sponseeId, required this.EventName, required this.EventType, required this.location, required this.imgURL, required this.startDate, required this.endDate, required this.startTime, required this.endTime, required this.Category, required  this.notes, required this.benefits, required this.NumberOfAttendees, required this.timeStamp});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              Container(
                height: 440,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 51, 45, 81),
                  image: DecorationImage(
                    image: imgURL.isNotEmpty
                        ? NetworkImage(imgURL)
                        : const NetworkImage(
                            'https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk='),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
  decoration: const BoxDecoration(
    color: Color.fromARGB(255, 51, 45, 81),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  ),
  height: 75,
  padding: const EdgeInsets.fromLTRB(16, 0, 0, 0), // Adjust the padding as needed
  child: Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      const Text(
        "Event Details",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 40), // Adjust the spacing as needed
    ],
  ),
)

            ],
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            EventName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            EventType,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(height: 30, thickness: 2),
                          // Info Rows
                        
                          _buildInfoRow(Icons.calendar_today, "${startDate} - ${endDate}", "Date"),
                          _buildInfoRow(Icons.access_time, "${startTime}-${endTime}", "Time"),
                          _buildInfoRow(Icons.person, NumberOfAttendees, "Attendees"),
                          const SizedBox(height: 20),
                  
                          const Text(
                            "Categories",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 4,
                            children: Category.map((category) {
                              return Chip(
                                label: Text(category),
                                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                shadowColor: const Color.fromARGB(255, 91, 79, 158),
                                elevation: 3,
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 91, 79, 158),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                  
                          const Text(
                            "Benefits",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            benefits ?? "No benefits available",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                  
                          const Text(
                            "Notes",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            (notes.isNotEmpty)
                                ? notes
                                : "There are no notes available",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                  
                          Center(
                            child: SizedBox(
                              height: 55, //height of button
                              width: 190,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return sendOffer(
                                        EventId: EventId,
                                        sponsorId: sponsorID,
                                        sponseeId: sponseeId,
                                        Category: Category, 
                                        TimeStamp: timeStamp,
                                        );
                                    },
                                  );
                                    },
                        
                                style: ElevatedButton.styleFrom(
                                 backgroundColor: const Color.fromARGB(255, 91, 79, 158),
                                //  primary: Color(0xFF6A62B6),
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Send offer',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          if (text != null && text.isNotEmpty)
          Icon(
            icon,
            size: 40,
            color: const Color.fromARGB(255, 91, 79, 158),
          ),
          const SizedBox(width: 10), // Adjust the spacing as needed
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (text != null && text.isNotEmpty)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              if (text != null && text.isNotEmpty) 
              Text(
                text,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class sendOffer extends StatefulWidget {
  final String EventId;
  final String sponseeId;
  final String? sponsorId;
  final List<String> Category;
  final String TimeStamp;


  const sendOffer({super.key, 
    required this.EventId,
    required this.sponseeId,
    required this.sponsorId,
    required this.Category,
     required this.TimeStamp, 
  });

  @override
  _sendOfferState createState() => _sendOfferState();
}
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

class _sendOfferState extends State<sendOffer> {
  Set<String> filters = <String>{};
  TextEditingController notesController = TextEditingController();
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;
  
@override
  Future<void> initState() async {
    super.initState();
   // requestPermission();
     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification!.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                  channel.id, channel.name,
                  playSound: true,
                  icon: '@mipmap/sponsitelogodark'),
            ));
      }
    }); 
  }
 /* void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print('User granted permission');
    } else if(settings.authorizationStatus==AuthorizationStatus.provisional){
      print('User declined or has granted permission');
    }
  }*/
  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  void _showEmptyFormAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
            data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child:
      AlertDialog(
          title: const Text('Empty Offer'),
          // backgroundColor: Colors.white,
          content: const Text(
              'Please select at least one category before sending the offer',style: TextStyle(fontSize: 20),),
          actions: [
             TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
              },
              child:const  Text('OK',style: TextStyle(color:Color.fromARGB(255,51,45,81), fontSize: 20),),
            ),
          ],
        ));
      },
    );
  }
  Future<String?> _retrieveSponseeToken(String id) async {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  final DataSnapshot dataSnapshot = (await databaseReference.child('userTokens').child(id).once()).snapshot;
   final Map<dynamic, dynamic>? data = dataSnapshot.value as Map<dynamic, dynamic>?;
  if (data != null && data.containsKey('token')) {
    return data['token'].toString();
  }
  
  return null;
}

void _sendOffer() async {
  DatabaseReference offersRef = database.child('offers');
  DatabaseEvent dataSnapshot = await offersRef.once();

  if (dataSnapshot.snapshot.value != null) {
    Map<dynamic, dynamic> offersData = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
    bool offerExists = offersData.values.any((offer) {
      return offer["EventId"] == widget.EventId &&
             offer["sponsorId"] == widget.sponsorId;
    });

    if (offerExists) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Offer Already Sent'),
            content: const Text(
              'You have already sent an offer for this event.',
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Color.fromARGB(255, 51, 45, 81),
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      if (filters.isEmpty) {
        _showEmptyFormAlert();
      } else {
        // Filters are not empty, so proceed to send the offer
        List<String> selectedCategories = filters.toList(); // Convert set to list

        // Create an Offer object
        Offer offer = Offer(
          EventId: widget.EventId,
          sponseeId: widget.sponseeId,
          sponsorId: widget.sponsorId ?? "",
          notes: notesController.text,
          Category: selectedCategories,
          TimeStamp: widget.TimeStamp ,
        );

        // Save the offer to the database
        DatabaseReference newOfferRef = offersRef.push();

        await newOfferRef.set({
          "EventId": offer.EventId,
          "sponseeId": offer.sponseeId,
          "sponsorId": offer.sponsorId,
          "Category": offer.Category,
          "notes": offer.notes,
          "TimeStamp": offer.TimeStamp,
        });
//await sendNotification(offer.sponseeId);
        setState(() {
          filters.clear();
        });
  Navigator.of(context).pop();
        // Show a success message
        showDialog(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.of(context).pop(true);
            });
            return Theme(
              data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color.fromARGB(255, 91, 79, 158),
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your offer was sent successfully!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  } else {
    if (filters.isEmpty) {
      _showEmptyFormAlert();
    } else {
      // Filters are not empty, so proceed to send the offer
      List<String> selectedCategories = filters.toList(); // Convert set to list

      // Create an Offer object
      Offer offer = Offer(
        EventId: widget.EventId,
        sponseeId: widget.sponseeId,
        sponsorId: widget.sponsorId ?? "",
        notes: notesController.text,
        Category: selectedCategories,
       TimeStamp: widget.TimeStamp ,
      );

      // Save the offer to the database
      DatabaseReference newOfferRef = offersRef.push();

      await newOfferRef.set({
        "EventId": offer.EventId,
        "sponseeId": offer.sponseeId,
        "sponsorId": offer.sponsorId,
        "Category": offer.Category,
        "notes": offer.notes,
        "TimeStamp": offer.TimeStamp,
        
      });
      pushNotificationsSpecificDevice(
                            title: 'New Offer',
                            body: 'You got a new offer for your event',
                            token: _retrieveSponseeToken(offer.sponseeId) as String
                          );
//await sendNotification(offer.sponseeId);
      setState(() {
        filters.clear();
      });
  Navigator.of(context).pop();
      // Show a success message
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
          });
          return Theme(
            data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Color.fromARGB(255, 51, 45, 81),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your offer was sent successfully!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
   /*Future<void> sendNotification(String id) async {
    String? mtoken = await _retrieveSponseeToken(id);
    print('im here deema!!!!!!!!!!!!!');
  //final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');
  var data = {
    'notification': {
      'title': 'New Offer!',
      'body': 'You received a new offer for your event',
    },
    'data': {
      // Add any additional data you want to send
    },
    'to': '/topics/$id',
  };
  print('$mtoken');

  //var response = await http.post(Uri.parse(url));
  await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: {
      'Authorization': 'key=AAAAw5lT-Yg:APA91bE4EbR1XYHUoMl-qZYAFVsrtCtcznSsh7RSCSZ-yJKR2_bdX8f9bIaQgDrZlEaEaYQlEpsdN6B6ccEj5qStijSCDN_i0szRxhap-vD8fINcJAA-nK11z7WPzdZ53EhbYF5cp-ql',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  /*if (response.statusCode == 200) {
    print('Notification sent successfully.');
  } else {
    print('Failed to send notification: ${response.reasonPhrase}');
  }*/
}*/
Future<bool> pushNotificationsSpecificDevice({
    required String token,
    required String title,
    required String body,
  }) async {
    String dataNotifications = '{ "to" : "$token",'
        ' "notification" : {'
        ' "title":"$title",'
        '"body":"$body"'
        ' }'
        ' }';

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key= AAAAw5lT-Yg:APA91bE4EbR1XYHUoMl-qZYAFVsrtCtcznSsh7RSCSZ-yJKR2_bdX8f9bIaQgDrZlEaEaYQlEpsdN6B6ccEj5qStijSCDN_i0szRxhap-vD8fINcJAA-nK11z7WPzdZ53EhbYF5cp-ql',
      },
      body: dataNotifications,
    );
    return true;
  }

@override
Widget build(BuildContext context) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 51, 45, 81),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Offer',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white, // Changed to white
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(children: [
                  Text(
                    'What do you want to offer?',
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Color.fromARGB(255, 51, 45, 81),
                      fontSize: 20 ,
                    ),
                  ),],),
                  Wrap(
                    spacing: 9.0,
                    children: widget.Category.map((category) {
                      return FilterChip(
                        label: Text(
                          category,
                          style: const TextStyle(color: Colors.white),
                        ),
                        selected: filters.contains(category),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              filters.add(category);
                            } else {
                              filters.remove(category);
                            }
                          });
                        },
                        backgroundColor: const Color.fromARGB(255, 202, 202, 204),
                        labelStyle: const TextStyle(
                          color: Color(0xFF4A42A1),
                        ),
                        elevation: 3,
                        selectedColor: const Color(0xFF4A42A1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 17),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                        
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: notesController,
                        maxLength: 600,
                        decoration: const InputDecoration(
                          hintText: 'Enter notes or additional information',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 20),
                        maxLines: 9,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _sendOffer();
                          },
                      style: ElevatedButton.styleFrom(
                         foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 91, 79, 158),
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Send Offer',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}