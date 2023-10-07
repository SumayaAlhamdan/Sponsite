import 'dart:convert';
import 'dart:ffi';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:sponsite/local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sponsite/widgets/customAppBarwithNav.dart';  
import 'package:sponsite/screens/view_others_profile.dart';

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
  final String NumberOfAttendees;
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
    required this.notes,
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
  final String NumberOfAttendees;
  final String timeStamp;
  final String sponseeName;
  final String sponseeImage;

  RecentEventsDetails(
      {super.key,
      required this.sponsorID,
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
      required this.notes,
      required this.benefits,
      required this.NumberOfAttendees,
      required this.timeStamp,
      required this.sponseeImage,
      required this.sponseeName});

  @override
  Widget build(BuildContext context) {
    GoogleMapController? mapController;

    double latitude = 0;
    double longitude = 0;
    LatLng loc = LatLng(latitude, longitude);

    void getloc() {
      List<String> parts = location.split(',');
      latitude = double.parse(parts[0]);
      longitude = double.parse(parts[1]);
      loc = LatLng(latitude, longitude);
    }

    if (location != "null") getloc();

    Widget buildMap() {
      print("here!!");
      return Stack(
        children: [
          Container(
            height: 500,
            child: GoogleMap(
              onMapCreated: (controller) {
                // setState(() {
                mapController = controller;
                // });
              },
              initialCameraPosition: CameraPosition(
                target: loc, // Initial map location
                zoom: 15.0,
                // Initial zoom level
              ),
              markers: {
                Marker(
                  markerId: MarkerId(
                      "EventLoc"), // A unique identifier for the marker
                  position:
                      loc, // Coordinates where the marker should be placed
                  infoWindow: InfoWindow(
                      title: "Event Location"), // Optional info window
                ),
              },
            ),
          ),
        ],
      );
    }

    Future<String> getAddressFromCoordinates(
        double latitude, double longitude) async {
      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          String address =
              '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
          ; // You can access various fields like street, city, country, etc.
          return address;
        } else {
          return "Address not found";
        }
      } catch (e) {
        print("Error retrieving address: $e");
        return "Error retrieving address";
      }
    }

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
             CustomAppBar(  
          title: 'Event Details',
        ),
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
                          Text(
                            EventName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Colors.black87,
                            ),
                          ),

                          Text(
                            EventType,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(146, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(sponseeImage),
                                  backgroundColor: Colors.transparent,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ViewOthersProfile(
                                        'Sponsees', sponseeId),
                                  ));
                                },
                              ),

                              SizedBox(width: 10),
                              // Add some space between the CircleAvatar and Text
                              GestureDetector(
                                child: Expanded(
                                  child: Text(
                                    sponseeName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ViewOthersProfile(
                                        'Sponsees', sponseeId),
                                  ));
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 30, thickness: 2),

                          // Info Rows

                          _buildInfoRow(Icons.calendar_today,
                              "${startDate} - ${endDate}", "Date"),
                          _buildInfoRow(Icons.access_time,
                              "${startTime}-${endTime}", "Time"),
                          _buildInfoRow(
                              Icons.people, NumberOfAttendees, "Attendees"),
                          if (location != "null")
                            FutureBuilder<String>(
                              future: getAddressFromCoordinates(
                                  latitude, longitude),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text("Error: ${snapshot.error}");
                                } else if (!snapshot.hasData) {
                                  return Text("Address not found");
                                } else {
                                  return Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons
                                              .location_on, // Replace with the desired icon
                                          color: const Color.fromARGB(
                                              255,
                                              91,
                                              79,
                                              158), // Customize the icon color
                                          size: 40.0, // Customize the icon size
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            snapshot.data ?? "",
                                            style: TextStyle(
                                              fontSize: 22.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),

                          if (location != "null")
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: buildMap(),
                            ),

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
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                shadowColor:
                                    const Color.fromARGB(255, 91, 79, 158),
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
                                        EventName : EventName
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 51, 45, 81),
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
  final String EventName ;

  const sendOffer({
    super.key,
    required this.EventId,
    required this.sponseeId,
    required this.sponsorId,
    required this.Category,
    required this.TimeStamp,
    required this.EventName
  });

  @override
  _sendOfferState createState() => _sendOfferState();
}

class _sendOfferState extends State<sendOffer> {
  Set<String> filters = <String>{};
  TextEditingController notesController = TextEditingController();
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  initState() {
    super.initState();
    // AppNotifications.setupNotification();
    // requestPermission();
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
            data:
                Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: AlertDialog(
              title: const Text('Empty Offer'),
              // backgroundColor: Colors.white,
              content: const Text(
                'Please select at least one category before sending the offer',
                style: TextStyle(fontSize: 20),
              ),
              actions: [
               TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); 
            },
            child: Text(
              'OK',
              style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
            ),
          ),  
              ],  
            ));
      },
    );  
  }

  Future<String?> _retrieveSponseeToken(String id) async {
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference();
    final DataSnapshot dataSnapshot =
        (await databaseReference.child('userTokens').child(id).once()).snapshot;
    final Map<dynamic, dynamic>? data =
        dataSnapshot.value as Map<dynamic, dynamic>?;
    if (data != null && data.containsKey('token')) {
      return data['token'].toString();
    }

    return null;
  }

  void _sendOffer() async {
    DatabaseReference offersRef = database.child('offers');
    DatabaseEvent dataSnapshot = await offersRef.once();

    if (dataSnapshot.snapshot.value != null) {
      Map<dynamic, dynamic> offersData =
          dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
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
            onPressed: () {
              Navigator.of(context).pop();
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
      } else {
        if (filters.isEmpty) {
          _showEmptyFormAlert();
        } else {
          // Filters are not empty, so proceed to send the offer
          List<String> selectedCategories =
              filters.toList(); // Convert set to list

          // Create an Offer object
          Offer offer = Offer(
            EventId: widget.EventId,
            sponseeId: widget.sponseeId,
            sponsorId: widget.sponsorId ?? "",
            notes: notesController.text,
            Category: selectedCategories,
            TimeStamp: widget.TimeStamp,
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
            "Status": "Pending",
          });
          final sponseeToken = await _retrieveSponseeToken(offer.sponseeId);
          if (sponseeToken != null && user!.uid == offer.sponsorId) {
            sendNotificationToSponsee1(sponseeToken);
          }
          setState(() {
            filters.clear();
            bool offerSent = true;
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
                data: Theme.of(context)
                    .copyWith(dialogBackgroundColor: Colors.white),
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
        List<String> selectedCategories =
            filters.toList(); // Convert set to list

        // Create an Offer object
        Offer offer = Offer(
          EventId: widget.EventId,
          sponseeId: widget.sponseeId,
          sponsorId: widget.sponsorId ?? "",
          notes: notesController.text,
          Category: selectedCategories,
          TimeStamp: widget.TimeStamp,
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
        final sponseeToken = await _retrieveSponseeToken(offer.sponseeId);
        if (sponseeToken != null) {
          if (user!.uid == offer.sponsorId) {
            sendNotificationToSponsee1(sponseeToken);
          }
        }
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
              data: Theme.of(context)
                  .copyWith(dialogBackgroundColor: Colors.white),
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
                    const Row(
                      children: [
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
                            color: Color.fromARGB(255, 91, 79, 158),
                            fontSize: 20,
                          ),
                        ),  
                      ],
                    ),
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
                          backgroundColor:
                              const Color.fromARGB(255, 202, 202, 204),
                          labelStyle: const TextStyle(
                            color: Color(0xFF4A42A1),
                          ),
                          elevation: 3,
                          selectedColor: const Color.fromARGB(255, 91, 79, 158),
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
                          // sendNotificationToSponsee1(
                          //   _retrieveSponseeToken(widget.sponseeId)
                          //     as String);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromARGB(255, 51, 45, 81),
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

  Future<void> sendNotificationToSponsee1(String sponseeToken) async {
    final String serverKey =
        'AAAAw5lT-Yg:APA91bE4EbR1XYHUoMl-qZYAFVsrtCtcznSsh7RSCSZ-yJKR2_bdX8f9bIaQgDrZlEaEaYQlEpsdN6B6ccEj5qStijSCDN_i0szRxhap-vD8fINcJAA-nK11z7WPzdZ53EhbYF5cp-ql'; //
    final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> notification = {
      'body': 'You have a new Offer for ${widget.EventName} event .',
      'title': 'New Offer',
      'sound': 'default',
    };

    final Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      // Add any additional data you want to send
    };

    final Map<String, dynamic> body = {
      'notification': notification,
      'data': data,
      'to': sponseeToken, // The FCM token of the service provider
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print(
            'Error sending notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
