import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/view_others_profile.dart';

final DatabaseReference dbref = FirebaseDatabase.instance.ref();

class Offer {
  String eventId;
  String sponseeId;
  String sponsorId;
  String sponsorName;
  String sponsorImage;
  String status;
  double? rating;

  Offer({
    required this.eventId,
    required this.sponseeId,
    required this.sponsorId,
    required this.sponsorName,
    required this.sponsorImage,
    this.status = 'Pending',
    this.rating,
  });
}

class Rating extends StatefulWidget {
  Rating({
    this.EVENTid,
    this.EventName,
  });

  final String? EVENTid;
  final String? EventName;

  @override
  _Rating createState() => _Rating();
}

class _Rating extends State<Rating> {
  List<Offer> offers = [];
  List<String> ratedSponsors = [];

  @override
  void initState() {
    super.initState();
    _loadOffersFromFirebase();
    _loadRatedSponsors();
  }

  void _loadRatedSponsors() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    database.child('Ratings').onValue.listen((ratings) {
      if (ratings.snapshot.value != null) {
        Map<dynamic, dynamic> ratingsData =
            ratings.snapshot.value as Map<dynamic, dynamic>;
        List<String> ratedSponsorsList = [];

        ratingsData.forEach((key, value) {
          String ratedSponsor =
              '${value['offerId']}_${value['sponsorId']}';
          ratedSponsorsList.add(ratedSponsor);
        });

        setState(() {
          ratedSponsors = ratedSponsorsList;
        });
      }
    });
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
            iconSize: 40,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.EventName} Sponsors',
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
    final accepted = offers.where((offer) => offer.status == 'Accepted').toList();
    print("here are all accepted");
    print(accepted);

    if (accepted.isEmpty) {
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
          SizedBox(height: 20),
          Text(
            'This event has no sponsors',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ],
      );
    } else {
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
    bool alreadyRated =
        ratedSponsors.contains('${offer.eventId}_${offer.sponsorId}');

    return Container(
      margin: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
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
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Text(
                        offer.sponsorName,
                        style: TextStyle(
                          fontSize: 24,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!alreadyRated)
                          ElevatedButton(
                            onPressed: () {
                              _saveRating(offer, 0); // Change to initial value
                            },
                            child: Text('Rate'),
                          ),
                        for (double i = 1; i <= 5; i++)
                          GestureDetector(
                            child: Icon(
                              i <= (offer.rating ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.orange,
                              size: 30,
                            ),
                            onTap: () {
                              if (!alreadyRated) {
                                _saveRating(offer, i);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveRating(Offer offer, double rating) {
    dbref.child('Ratings').push().set({
      'rating': rating,
      'offerId': offer.eventId,
      'sponsorId': offer.sponsorId,
    });

    setState(() {
      offer.rating = rating;
      ratedSponsors.add('${offer.eventId}_${offer.sponsorId}');
    });
  }
}
