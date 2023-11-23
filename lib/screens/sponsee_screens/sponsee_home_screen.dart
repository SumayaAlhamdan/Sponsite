import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/view_others_profile.dart';

class Sponsor {
  String sponsorId;
  String sponsorImage;
  String sponsorName;
  String rate;

  Sponsor({
    required this.sponsorId,
    required this.sponsorImage,
    required this.sponsorName,
    required this.rate,
  });
}

User? user = FirebaseAuth.instance.currentUser;
String? sponseeID;

void check() {
  if (user != null) {
    sponseeID = user?.uid;
    print('Sponsee ID: $sponseeID');
  } else {
    print('User is not logged in.');
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 30;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SponseeHome extends StatefulWidget {
  const SponseeHome({Key? key}) : super(key: key);

  @override
  _SponseeHomeState createState() => _SponseeHomeState();
}

class _SponseeHomeState extends State<SponseeHome> {
  void setUpPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic(user!.uid);
  }

  @override
  void initState() {
    super.initState();
    check();
    setUpPushNotifications();
    _loadSponsorsFromFirebase();
  }

  List<Sponsor> sponsors = [];

  void _loadSponsorsFromFirebase() async {
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  database.child('Sponsors').onValue.listen((sponsorsSnapshot) {
    if (sponsorsSnapshot.snapshot.value != null) {
      Map<dynamic, dynamic> sponsorData =
          sponsorsSnapshot.snapshot.value as Map<dynamic, dynamic>;

      List<Sponsor> allSponsors = [];

      sponsorData.forEach((key, value) {
        allSponsors.add(Sponsor(
          sponsorName: value['Name'] as String? ?? '',
          sponsorId: key,
          sponsorImage: value['Picture'] as String? ?? '',
          rate: value['Rate'].toString(),
        ));
      });

      allSponsors.sort((a, b) => b.rate.compareTo(a.rate));

      setState(() {
        int displayCount = allSponsors.length < 10 ? allSponsors.length : 10;
        sponsors = List<Sponsor>.from(allSponsors.getRange(0, displayCount));
        print(sponsors);
      });
    }
  });
}


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
         child:
         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
     
            Stack(
              children: [
                ClipPath(
                  clipper: CurveClipper(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color.fromARGB(255, 91, 79, 158),
                          Color.fromARGB(255, 51, 45, 81),
                        ],
                      ),
                    ),
                    height: 200.0,
                  ),
                ),
              ],
                    ),
                    const SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              "Popular Sponsors",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Color.fromARGB(255, 91, 79, 158),
                              ),
                            ),
                          ),
                         if (sponsors.isEmpty)
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height:screenHeight*0.3),
          Center(
              child: Image.asset(
                'assets/NoSponsorsIcon.png',
                fit: BoxFit.cover, // Set the BoxFit property as needed
              ),
            ),
              ],
            )
                         
                         else   
            SizedBox(
              height: screenHeight,
              child: Scrollbar(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12.0, 0),
                  shrinkWrap: true,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 9,
                  ),
                  itemCount: sponsors.length,
                 itemBuilder: (context, index) {
                    Sponsor sponsor = sponsors[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewOthersProfile(
                              'Sponsors',
                              sponsor.sponsorId,
                            ),
                          ),
                        );
                      },
                child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              sponsor.sponsorImage.isNotEmpty
                  ? Image.network(
                      sponsor.sponsorImage,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      'https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk=',
                      fit: BoxFit.cover,
                    ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.white.withOpacity(0.8),
                  child: Text(
                    sponsor.sponsorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
                 
                 }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
