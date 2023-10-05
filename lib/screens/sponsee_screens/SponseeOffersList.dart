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
  String startDate;
  String startTime;

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
    required this.startDate,
    required this.startTime,
  });

  int get timeStampAsInt => int.tryParse(timeStamp) ?? 0;
}

class SponseeOffersList extends StatefulWidget {
  SponseeOffersList({
    required this.EVENTid,
    Key? key,
    required this.EventName,
  }) : super(key: key);

  final String? EVENTid;
  final String? EventName;

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
    Map<String, String> startDates = {};
    Map<String, String> startTimes = {};

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

            loadedOffers.add(Offer(
                eventId: key,
                sponseeId: value['sponseeId'] as String? ?? '',
                categories: categoryList,
                notes:
                    value['notes'] as String? ?? 'There are no notes available',
                sponsorId: value['sponsorId'] as String? ?? '',
                sponsorName: 'krkr',
                sponsorImage: '',
                timeStamp: timestampString,
                status: value['Status'] as String? ?? 'Pending',
                startDate: '',
                startTime: '' // Load the start date
                ));
          }
        });

        database.child('Sponsors').onValue.listen((spons) {
          if (spons.snapshot.value != null) {
            Map<dynamic, dynamic> sponsorData =
                spons.snapshot.value as Map<dynamic, dynamic>;

            sponsorData.forEach((key, value) {
              sponsorNames[key] = value['Name'] as String? ?? '';
              sponsorImages[key] = value['Picture'] as String? ?? '';
            });

            for (var offer in loadedOffers) {
              offer.sponsorName = sponsorNames[offer.sponsorId] ?? '';
              offer.sponsorImage = sponsorImages[offer.sponsorId] ?? '';
            }
          }
        });

        database.child('sponseeEvents').onValue.listen((Date) {
          if (Date.snapshot.value != null) {
            Map<dynamic, dynamic> date =
                Date.snapshot.value as Map<dynamic, dynamic>;
            date.forEach((key, value) {
              startDates[key] = value['startDate'] as String? ?? '';
              startTimes[key] = value['startTime'] as String? ?? '';
            });

            // Update the start dates in the offers
            for (var offer in loadedOffers) {
              offer.startDate = startDates[offer.eventId] ?? '';
              offer.startTime = startTimes[offer.eventId] ?? '';
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
    print('prining first ! ');
    print(offer.startDate + offer.startTime);

    try {
      final offerTimestamp = DateTime.parse(offer.timeStamp);

      var eventStartDateTime =
          DateTime.parse(offer.startDate + ' ' + offer.startTime);

      // Adjust for 12-hour time format and space
      final timeParts = offer.startTime.split(' ');
      final eventHour = int.parse(timeParts[0].split(':')[0]);
      final eventMinute = int.parse(timeParts[0].split(':')[1]);

      if (timeParts[1].toLowerCase() == 'pm' && eventHour < 12) {
        eventStartDateTime = eventStartDateTime.add(Duration(hours: 12));
      }

      // Calculate the time difference in days
      final timeDifference =
          eventStartDateTime.difference(offerTimestamp).inDays;

      if (timeDifference > 0) {
        final threshold = timeDifference ~/ 2;
        final expiresIn = timeDifference - threshold;

        if (expiresIn == 0) {
          return 'Expires today';
        } else if (expiresIn == 1) {
          return 'Expires in 1 day';
        } else {
          return 'Expires in $expiresIn days';
        }
      } else {
        return 'Expired';
      }
    } catch (e) {
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
          title: Center(
            child: Text(
              '${widget.EventName} Event Offers',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
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

  bool isExpanded = false;

  @override
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
                  isExpanded = !isExpanded;
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
                        'Posted: ${formatTimeAgo(timestamp)}',
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
              padding: EdgeInsets.only(bottom: 16),
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
                              ViewOthersProfile('Sponsors', sponsorID)));
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
                                  ViewOthersProfile('Sponsors', sponsorID)));
                        },
                      ),
                      Text(
                        calculateExpiry(offer),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ),
            if (isExpanded)
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 4,
                      children: offer.categories.map((category) {
                        return Chip(
                          label: Text(category),
                          backgroundColor: Color.fromARGB(255, 91, 79, 158),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      offer.notes,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                        height:
                            20), // Additional height to separate from action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showConfirmationDialog("Accept", offer);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            minimumSize: Size(120, 50),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: Text(
                            'Accept',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            _showConfirmationDialog("Reject", offer);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            minimumSize: Size(120, 50),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: Text(
                            'Reject',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ],
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
