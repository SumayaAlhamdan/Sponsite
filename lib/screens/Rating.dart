import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sponsite/screens/chatPage.dart';
import 'package:sponsite/screens/view_others_profile.dart';

final DatabaseReference dbref = FirebaseDatabase.instance.reference();

class Offer {
  String eventId;
  String sponseeId;
  String sponsorId;
  String sponsorName;
  String sponsorImage;
  String status;

  Offer({
    required this.eventId,
    required this.sponseeId,
    required this.sponsorId,
    required this.sponsorName,
    required this.sponsorImage,
    this.status = 'Pending',
  });


}

class Rating extends StatefulWidget {
  Rating({
     this.EVENTid,
     this.EventName,
  }) ;

  final String? EVENTid;
  final String? EventName;
  @override
  _Rating createState() => _Rating();
}

class _Rating extends State<Rating> {
  List<Offer> offers = [];
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


    database.child('offers').onValue.listen((offer) {
      if (offer.snapshot.value != null) {
        Map<dynamic, dynamic> offerData =
            offer.snapshot.value as Map<dynamic, dynamic>;
        offerData.forEach((key, value) {
           print("Hi there is an event which is  : ") ; print(widget.EVENTid) ; print(widget.EventName) ; 
          if (value['EventId'] == widget.EVENTid) {
           
            try {
              loadedOffers.add(Offer(
                eventId: key,
                sponseeId: value['sponseeId'] as String? ?? '',
                sponsorId: value['sponsorId'] as String? ?? '',
                sponsorName: 'krkr',
                sponsorImage: '',
                status: value['Status'] as String? ?? 'Pending',
              ));
            } catch (e) {
              print('Error parsing timestamp: $e');
            }
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
            setState(() {
              offers = loadedOffers;
            });
          }
        });
      }
    });
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
        '${widget.EventName} Event Sponsors',
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
            Expanded(
              child: TabBarView(
                children: [
                  _buildSponsorsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
    Widget _buildSponsorsPage() {
    final accepted =
        offers.where((offer) => offer.status == 'Accepted').toList();
print("here are all accepted"); print(accepted) ; 
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
