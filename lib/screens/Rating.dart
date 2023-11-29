import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sponsite/screens/view_others_profile.dart';

final DatabaseReference dbref = FirebaseDatabase.instance.ref();

class Offer {
  String offerId;
  String eventId;
  String sponseeId;
  String sponsorId;
  String sponsorName;
  String sponsorImage;
  String status;
  double? ratings;
  bool rated ; 
  bool selected ;  // Updated property name

  Offer({
    required this.offerId,
    required this.eventId,
    required this.sponseeId,
    required this.sponsorId,
    required this.sponsorName,
    required this.sponsorImage,
    this.status = 'Pending',
    this.ratings, // Updated property name
    this.rated = false , 
    this.selected = false, 
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


 @override
void initState() {
  super.initState();
  if (!loaded) {
    _loadOffersFromFirebase();
    loaded = true;
  }
}

bool loaded = false;

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
             loadedOffers.clear();
        offerData.forEach((key, value) {
          if (value['EventId'] == widget.EVENTid) {
            try {
              loadedOffers.add(Offer(
                offerId: key,
                eventId: value['EventId'] as String? ?? '',
                sponseeId: value['sponseeId'] as String? ?? '',
                sponsorId: value['sponsorId'] as String? ?? '',
                sponsorName: 'Roshn',
                sponsorImage: '',
                status: value['Status'] as String? ?? 'Pending',
            //    ratings: (value['sponsorRating'] as num).toDouble() 
 ratings: value['sponsorRating'] != null
                  ? (value['sponsorRating'] as num).toDouble()
                   : null,
                      rated: value['sponsorRating'] != null,
              ));
            } catch (e) {
              print('Error parsing timestamp: $e');
            }
          }
        });

          // After loading offers, update sponsors

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
            _updateSponsors(loadedOffers, sponsorNames, sponsorImages);

  }

   void _updateSponsors(
      List<Offer> loadedOffers, Map<String, String> sponsorNames, Map<String, String> sponsorImages) {
    for (var offer in loadedOffers) {
      offer.sponsorName = sponsorNames[offer.sponsorId] ?? '';
      offer.sponsorImage = sponsorImages[offer.sponsorId] ?? '';
    }
    setState(() {
      offers = loadedOffers;
    });
  }

 

  late double newRate ; 
  bool issubmitted = false  ;

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
            spreadRadius: 4,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(13.0),
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
                  ),
                  SizedBox(height: 5),
                  Row(
                    
    
                    children: [
                      
                      Padding(  padding: const EdgeInsets.only(left: 400,top: 40)), 
                    // If  are null
                    if (offer.ratings == null) 
Column(
  children: !offer.rated
      ? [
          Row(
            children: [

              RatingBar.builder(
                initialRating: offer.ratings ?? 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 28,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    newRate = rating;
                    offer.selected = true; // Set the flag to true when a rating is selected
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10), // Add some spacing between stars and button
          Row(
            children: [
              ElevatedButton(
                onPressed: offer.selected
                    ? () {
                        _submitRating(offer, newRate);
                        newRate = 0;
                        calculateRating(offer.sponsorId);
                        setState(() {
                          offer.rated = true; // Mark the offer as rated
                          issubmitted = true;
                        });
                      }
                    : null, // Disable the button if a rating is not selected
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 91, 79, 158),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 5),
                    Text(
                      'Rate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]
      : [
          Row(

            children: [
              Text(
                'Rated with:',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
              Icon(
                Icons.star,
                color: Colors.yellow,
                size: 30,
              ),
              Text(
                ' ${offer.ratings}',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
)

// If ratings are not null
 else 
  Column(
    children: [
      Row(
        children: [
          Text(
            'Rated with:',
            style: TextStyle(
              fontSize: 26,
              color: Colors.black,
            ),
          ),
          Icon(
            Icons.star,
            color: Colors.yellow,
            size: 30,
          ),
          Text(
            ' ${offer.ratings}',
            style: TextStyle(
              fontSize: 26,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ],
  )

                     

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

double ratingSum = 0 ; 
int count = 0 ; 
double calculateRating(String sponsorID) {
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  database.child('offers').onValue.listen((rates) {
    if (rates.snapshot.value != null) {
      Map<dynamic, dynamic> offerData =
          rates.snapshot.value as Map<dynamic, dynamic>;
      offerData.forEach((key, value) {
        if (value['sponsorId'] == sponsorID) {
          if (value['sponsorRating'] != null) {
            ratingSum += value['sponsorRating'];
            count++;
          }
        }
      });

      // Update the 'Rate' value under the specified sponsorID in 'Sponsors'
      final DatabaseReference databaseSponsor = FirebaseDatabase.instance.ref();
      final DatabaseReference sponsorRef =
          databaseSponsor.child('Sponsors').child(sponsorID);

      sponsorRef.child('Rate').set((ratingSum/count).toStringAsFixed(1)) ;
    }
  });

  // Return 0 if the 'offers' data is null to avoid division by zero
  return ratingSum / count;
}



  void _submitRating(Offer offer,double rating) async {
    try {
      final DatabaseReference database = FirebaseDatabase.instance.ref();
      final DatabaseReference offerRef =
          database.child('offers').child(offer.offerId);

      // Update the rating in the 'offers' node
      await offerRef.child('sponsorRating').set(rating);

      // Perform any additional actions or UI updates as needed

    } catch (error) {
      print('Error submitting rating: $error');
      // Handle errors accordingly
    }
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
    final accepted =
        offers.where((offer) => offer.status == 'Accepted').toList();

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
      return ListView.builder(
        itemCount: accepted.length,
        itemBuilder: (context, index) {
          return _buildOfferCard(accepted[index]);
        },
      );
    }
  }




  }

