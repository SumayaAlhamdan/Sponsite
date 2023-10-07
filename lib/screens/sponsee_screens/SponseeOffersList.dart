import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sponsite/screens/chatPage.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_home_screen.dart';
import 'package:sponsite/screens/view_others_profile.dart';
import 'package:sponsite/widgets/customAppBar.dart';

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
  bool isExpanded;
  String sponsorEmail;

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
    this.isExpanded = false,
    required this.sponsorEmail,
  });

  int get timeStampAsInt => int.tryParse(timeStamp) ?? 0;
}

class SponseeOffersList extends StatefulWidget {
  SponseeOffersList({
    required this.EVENTid,
    Key? key,
    required this.EventName,
    required this.startDate,
    required this.startTime,
  }) : super(key: key);

  final String? EVENTid;
  final String? EventName;
  final String? startDate;
  final String? startTime;

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

    database.child('offers').onValue.listen((offer) {
      if (offer.snapshot.value != null) {
        Map<dynamic, dynamic> offerData =
            offer.snapshot.value as Map<dynamic, dynamic>;
        offerData.forEach((key, value) {
          List<String> categoryList = [];
          if (value['Category'] is List<dynamic>) {
            categoryList = (value['Category'] as List<dynamic>)
                .map((category) => category.toString())
                .toList();
          }
          if (value['EventId'] == widget.EVENTid) {
            String timestampString = value['TimeStamp'] as String? ?? '';
            try {
              // Trim spaces and ensure it has a valid format before parsing
              timestampString = timestampString.trim();
              DateTime timestamp =
                  DateFormat("yyyy-MM-dd HH:mm:ss.S").parse(timestampString);

              loadedOffers.add(Offer(
                eventId: key,
                sponseeId: value['sponseeId'] as String? ?? '',
                categories: categoryList,
                notes:
                    value['notes'] as String? ?? 'There are no notes available',
                sponsorId: value['sponsorId'] as String? ?? '',
                sponsorName: 'krkr',
                sponsorImage: '',
                timeStamp:
                    timestamp.toLocal().toString(), // Convert to local time
                status: value['Status'] as String? ?? 'Pending',
                isExpanded: false,
                sponsorEmail: '',
              ));
            } catch (e) {
              print('Error parsing timestamp: $e');
            }
          }
        });
// Rest of your code...
        database.child('Sponsors').onValue.listen((spons) {
          if (spons.snapshot.value != null) {
            Map<dynamic, dynamic> sponsorData =
                spons.snapshot.value as Map<dynamic, dynamic>;
            sponsorData.forEach((key, value) {
              sponsorNames[key] = value['Name'] as String? ?? '';
              sponsorImages[key] = value['Picture'] as String? ?? '';
              sponsorEmails[key] = value['Email'] as String? ?? '';
            });
            for (var offer in loadedOffers) {
              offer.sponsorName = sponsorNames[offer.sponsorId] ?? '';
              offer.sponsorImage = sponsorImages[offer.sponsorId] ?? '';
              offer.sponsorEmail = sponsorEmails[offer.sponsorId] ?? '';
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
      final startDate = DateTime.parse(widget.startDate!);

      // Calculate the time difference in days between the offer timestamp and event start date
      final timeDifference = startDate.difference(offerTimestamp).inDays;

      // Calculate 50% of the time difference
      final remainingDays = (timeDifference * 0.5).round();

      if (remainingDays > 0) {
        if (remainingDays == 1) {
          return 'Expires in 1 day';
        } else {
          return 'Expires in $remainingDays days';
        }
      } else {
        // Check if the offer is still "Pending"
        if (offer.status == 'Pending') {
          // Update the status to "Expired" in the database
          dbref
              .child('offers')
              .child(offer.eventId)
              .update({'Status': 'Expired'});
          // Remove the expired offer from the list
          offers.remove(offer);
          return 'Expired';
        } else {
          return 'Expires Today';
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
        backgroundColor: Colors.white,
       appBar:  AppBar(
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
    iconSize: 40, 
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
          fontSize: 30, 
        ),
      ),      
    ],  
  ),
),
    
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
            'There are no new offers yet',
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
            'There are no accepted offers yet',
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
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
                    if (offer.status == 'Pending')
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
              padding: const EdgeInsets.only(left: 16),
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
                              builder: (context) => ViewOthersProfile(
                                  'Sponsors', offer.sponsorId)));
                        },
                      ),
                    ],
                  ),
                  SizedBox(width: 200),
                  Container(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              receiverUserEmail: offer.sponsorEmail,
                              receiverUserID: offer.sponsorId,
                              receiverUserName: offer.sponsorName,
                              pic: offer.sponsorImage,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 91, 79, 158),
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
                          SizedBox(width: 8),
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
                ],
              ),
            ),
            if (offer.isExpanded)
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Wrap(
                        spacing: 4,
                        children: offer.categories.map((category) {
                          return Chip(
                            label: Text(category.trim()),
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            shadowColor: const Color.fromARGB(255, 91, 79, 158),
                            elevation: 3,
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 91, 79, 158),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'Notes:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                   Padding(
  padding: const EdgeInsets.only(left: 16),
  child: Text(
    offer.notes != null && offer.notes.isNotEmpty ? offer.notes : "There are no notes available",
    style: TextStyle(
      fontSize: 20,
      color: Colors.black87,
    ),
  ),
),

                    SizedBox(height: 16),
                    if (offer.status ==
                        'Pending') // Only show Accept and Reject buttons for pending offers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog("Reject", offer);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(179, 203, 54, 43),
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
                          SizedBox(width: 30), // Adjust the width to add space
                          ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog("Accept", offer);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 51, 45, 81),
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
                    SizedBox(height: 20), // Adjust the height to add space
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
          title: Text(
            'Confirm $action',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: Text('Are you sure you want to $action this offer?'),
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
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
                        shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
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
                              'Offer was $action' + 'ed successfully!',
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
                    offers.clear(); // Remove the rejected offer from the list
                  });
                }

                setState(() {
                  showActions = false;
                });
              },
              child: Text('Confirm',
                  style: TextStyle(color: Color.fromARGB(255, 242, 241, 241))),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 51, 45, 81)),
                  //Color.fromARGB(255, 207, 186, 224),), // Background color
                  textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(fontSize: 16)), // Text style
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(16)), // Padding
                  elevation: MaterialStateProperty.all<double>(1), // Elevation
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Border radius
                      side: const BorderSide(
                          color: Color.fromARGB(
                              255, 255, 255, 255)), // Border color
                    ),
                  ),
                  minimumSize:
                      MaterialStateProperty.all<Size>(const Size(200, 50))),
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
      'body': 'Your ${widget.EventName} Offer status has been updated.',
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
