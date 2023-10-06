import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sponsite/screens/sponsor_screens/sponsor_home_screen.dart';
import 'package:sponsite/screens/view_others_profile.dart';

final DatabaseReference dbref = FirebaseDatabase.instance.reference();

class Offer {
  String eventId;
  String sponseeId;
  List<String> categories;
  String notes;
  String sponsorId;
  String sponsorName;
  String sponsorImage;
  String timeStamp;
  String status;
  bool isExpanded ; 
  String sponsorEmail ; 


  Offer({
    required this.eventId,
    required this.sponseeId,
    required this.categories,
    required this.notes,
    required this.sponsorId,
    required this.sponsorName,
    required this.sponsorImage,
    required this.timeStamp,
    this.status = 'Pending',
    this.isExpanded = false , 
    required this.sponsorEmail,
  
  });

  int get timeStampAsInt => int.tryParse(timeStamp) ?? 0;
}

class SponseeOffersList extends StatefulWidget {
  SponseeOffersList({
    required this.EVENTid,
    Key? key,
    required this.EventName, required this.startDate, required this.startTime,
  }) : super(key: key);

  final String? EVENTid;
  final String? EventName;
  final String? startDate ; 
    final String? startTime ; 


  @override
  _SponseeOffersListState createState() => _SponseeOffersListState();
}

class _SponseeOffersListState extends State<SponseeOffersList> {
  List<Offer> offers = [];
  bool showActions = true;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadOffersFromFirebase();
  }

void _loadOffersFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    offers.clear();
    List<Offer> loadedOffers = [];
    Map<String, String> sponsorNames = {};
    Map<String, String> sponsorImages = {};
    Map<String, String> sponsorEmails = {};

final startTimeParts = widget.startTime!.split(' ');
final startTime = DateFormat.jm().parse(startTimeParts[0] + ' ' + startTimeParts[1]);



    database.child('offers').onValue.listen((offer) {
      if (offer.snapshot.value != null) {
        Map<dynamic, dynamic> offerData = offer.snapshot.value as Map<dynamic, dynamic>;
        offerData.forEach((key, value) {
          List<String> categoryList = [];
          if (value['Category'] is List<dynamic>) {
            categoryList = (value['Category'] as List<dynamic>).map((category) => category.toString()).toList();
          }
          if (value['EventId'] == widget.EVENTid) {
            String timestampString = value['TimeStamp'] as String? ?? '';
            loadedOffers.add(Offer(
              eventId: key,
              sponseeId: value['sponseeId'] as String? ?? '',
              categories: categoryList,
              notes: value['notes'] as String? ?? 'There are no notes available',
              sponsorId: value['sponsorId'] as String? ?? '',
              sponsorName: 'krkr',
              sponsorImage: '',
              timeStamp: timestampString,
              status: value['Status'] as String? ?? 'Pending',
              isExpanded: false , 
              sponsorEmail:'',
            ));
          }
        });
        database.child('Sponsors').onValue.listen((spons) {
          if (spons.snapshot.value != null) {
            Map<dynamic, dynamic> sponsorData = spons.snapshot.value as Map<dynamic, dynamic>;
            sponsorData.forEach((key, value) {
              sponsorNames[key] = value['Name'] as String? ?? '';
              sponsorImages[key] = value['Picture'] as String? ?? '';
              sponsorEmails[key] = value['Email'] as String? ?? '';
            });
            for (var offer in loadedOffers) {
              offer.sponsorName = sponsorNames[offer.sponsorId] ?? '';
              offer.sponsorImage = sponsorImages[offer.sponsorId] ?? '';
              offer.sponsorEmail = sponsorEmails[offer.sponsorId]?? '';
            }
            setState(() {
              offers = loadedOffers;
            });
          }
        });
      }
    });
  }
 String calculateExpiry(Offer offer) {
  try {
    final offerTimestamp = DateTime.parse(offer.timeStamp);

    // Parse the start date and time
    final startDate = DateTime.parse(widget.startDate!);
    final startTimeParts = widget.startTime!.split(' ');
    final startTime = DateFormat.jm().parse(startTimeParts[0] + ' ' + startTimeParts[1]);

    // Calculate the event date and time
    final eventDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    final now = DateTime.now();

    // Calculate the time difference in days, excluding the starting day
    final timeDifference = eventDateTime.isAfter(now)
        ? eventDateTime.difference(now).inDays - 1
        : 0;

    // Calculate 50% of the time difference
    final remainingDays = (timeDifference * 0.5).round();

    if (remainingDays > 0) {
      if (remainingDays == 1) {
        return 'Expires in 1 day';
      } else {
        return 'Expires in $remainingDays days';
      }
    } else {
      // Check if the offer has expired
      if (now.isAfter(eventDateTime)) {
        // Update the status to "Expired" in the database
        dbref.child('offers').child(offer.eventId).update({'Status': 'Expired'});
        // Remove the expired offer from the list
        offers.remove(offer);
        return 'Expired';
      } else {
        return 'Expires soon';
      }
    }
  } catch (e) {
    print('Error: $e');
    return 'Invalid date or time format';
  }
}




  String formatTimeAgo(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final day = DateFormat.d().format(date);
    final month = DateFormat.MMM().format(date);
    final year = DateFormat.y().format(date);
    final hour = DateFormat.jm().format(date);

    final formattedTime = 'Posted: $day - $month - $year at $hour';

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
  backgroundColor: Color.fromARGB(255, 51, 45, 81),
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  ),
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.of(context).pop();
    },
  ),
  title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        '${widget.EventName} Event Offers',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
),

        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              color: Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.only(bottom: 20, top: 50),
              child: TabBar(
                indicatorColor: Color.fromARGB(255, 51, 45, 81),
                tabs: const [
                  Tab(
                    child: Text(
                      'Current Offers',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Sponsors',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCurrentOffersPage(),
                  _buildSponsorsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentOffersPage() {
    final currentOffers =
        offers.where((offer) => offer.status == 'Pending').toList();

    if (currentOffers.isEmpty) {
      // If there are no pending offers, display the empty state message
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 282,
            height: 284,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Add Files (1).png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SizedBox(height: 20), // Adjust the spacing as needed
          Text(
            'There Are No New Offers Yet',
            style: TextStyle(
              fontSize: 24, // Adjust the font size as needed
            ),
          ),
        ],
      );
    } else {
      // If there are pending offers, display them
      return SingleChildScrollView(
        child: Column(
          children: currentOffers.map((offer) {
            return _buildOfferCard(offer);
          }).toList(),
        ),
      );
    }
  }

  Widget _buildSponsorsPage() {
    final accepted =
        offers.where((offer) => offer.status == 'Accepted').toList();

    if (accepted.isEmpty) {
      // If there are no accepted offers, display the empty state message with the image
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 282,
            height: 284,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/NoSponsorsIcon.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SizedBox(height: 20), // Adjust the spacing as needed
          Text(
            'There Are No Accepted Offers Yet',
            style: TextStyle(
              fontSize: 24, // Adjust the font size as needed
            ),
          ),
        ],
      );
    } else {
      // If there are accepted offers, display them
      return SingleChildScrollView(
        child: Column(
          children: accepted.map((offer) {
            return _buildOfferCard(offer);
          }).toList(),
        ),
      );
    }
  }
Widget _buildOfferCard(Offer offer) {
  final timestamp = DateTime.parse(offer.timeStamp).millisecondsSinceEpoch;

  return Container(
    margin: EdgeInsets.all(10),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Radius for the card
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            spreadRadius: 2, // Spread radius for the shadow
            blurRadius: 4, // Blur radius for the shadow
            offset: Offset(0, 2), // Offset for the shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                offer.isExpanded = !offer.isExpanded;
              });
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Color.fromARGB(193, 51, 45, 81),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '${formatTimeAgo(timestamp)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Text(
                      calculateExpiry(offer),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16), // Add left padding to the Sponsor section
            child: Row(
              children: [
                GestureDetector(
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.black,
                      image: DecorationImage(
                        image: NetworkImage(offer.sponsorImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ViewOthersProfile('Sponsors', offer.sponsorId)));
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sponsor',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    GestureDetector(
                      child: Text(
                        offer.sponsorName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ViewOthersProfile('Sponsors', offer.sponsorId)));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (offer.isExpanded)
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10), // Add spacing between Sponsor and Categories
                  Padding(
                    padding: const EdgeInsets.only(left: 16), // Add left padding to Categories
                    child: Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 10), // Add spacing below Categories
                  Padding(
                    padding: const EdgeInsets.only(left: 16), // Add left padding to Categories
                    child: Wrap(
                      spacing: 4,
                      children: offer.categories.map((category) {
                        return Chip(
                          label: Text(category.trim()),
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          shadowColor: const Color.fromARGB(255, 91, 79, 158),
                          elevation: 3,
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 91, 79, 158),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16), // Add spacing below Categories
                  Padding(
                    padding: const EdgeInsets.only(left: 16), // Add left padding to Notes
                    child: Text(
                      'Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 4), // Add spacing below Notes title
                  Padding(
                    padding: const EdgeInsets.only(left: 16), // Add left padding to Notes
                    child: Text(
                      offer.notes,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 16), // Add spacing below Notes content
                  Padding(
                    padding: const EdgeInsets.only(left: 16), // Add left padding to Chat button
                    child: Container(
                      width: 120, // Adjust the width as needed
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your chat logic here
                        },
                        style: ElevatedButton.styleFrom(
                          primary:  const Color.fromARGB(255, 91, 79, 158),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8), // Adjust the spacing between the icon and text
                            Text(
                              'Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10), // Add spacing below Chat button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog("Reject", offer);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 30), // Add spacing between the "Reject" and "Accept" buttons
                      ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog("Accept", offer);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Accept',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // Add space between the action buttons and the arrow
                ],
              ),
            ),
          GestureDetector(
            onTap: () {
              setState(() {
                offer.isExpanded = !offer.isExpanded;
              });
            },
            child: Icon(
              offer.isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
          ),
        ],
      ),
    ),
  );
}




  void _showConfirmationDialog(String action, Offer offer) {
  showDialog(
    context: context,
    builder: (context) {
      final uniqueKey = GlobalKey();
      return AlertDialog(
        key: uniqueKey,
        title: Text('Confirm $action'),
        content: Text('Are you sure you want to $action this offer?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final sponsorToken =
                  await _retrieveSponsorToken(offer.sponsorId);
              if (sponsorToken != null && user!.uid == offer.sponseeId) {
                sendNotificationToSponsor1(sponsorToken);
              }
              if (action == "Accept") {
                offer.status = 'Accepted';

                setState(() {
                  offers.clear();
                });

                dbref
                    .child('offers')
                    .child(offer.eventId)
                    .update({'Status': "Accepted"});
              } else {
                dbref
                    .child('offers')
                    .child(offer.eventId)
                    .update({'Status': "Rejected"});

                setState(() {
                  offers.remove(offer); 
                    offers.clear();// Remove the rejected offer from the list
                });
              }

              setState(() {
                showActions = false;
              });
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}

  Future<void> sendNotificationToSponsor1(String sponsorToken) async {
    final String serverKey =
        'AAAAw5lT-Yg:APA91bE4EbR1XYHUoMl-qZYAFVsrtCtcznSsh7RSCSZ-yJKR2_bdX8f9bIaQgDrZlEaEaYQlEpsdN6B6ccEj5qStijSCDN_i0szRxhap-vD8fINcJAA-nK11z7WPzdZ53EhbYF5cp-ql'; //
    final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> notification = {
      'body': 'Your Offer status has been updated.',
      'title': 'Status update',
      'sound': 'default',
    };

    final Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      // Add any additional data you want to send
    };

    final Map<String, dynamic> body = {
      'notification': notification,
      'data': data,
      'to': sponsorToken, // The FCM token of the service provider
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

  Future<String?> _retrieveSponsorToken(String id) async {
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
}
