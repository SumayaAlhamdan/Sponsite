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

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> Sponsors = [];
  List<Map<String, dynamic>> sponsees = [];
  List<Map<String, dynamic>> filteredSponsors = [];
  List<Map<String, dynamic>> filteredSponsees = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String searched = '';

  @override
  void initState() {
    super.initState();
    check();
    setUpPushNotifications();
    _loadSponsorsFromFirebase();
    fetchSponsors().listen((sponsorsData) {
      setState(() {
        Sponsors = sponsorsData;
        filteredSponsors = Sponsors;
      });
    });
    fetchSponsees().listen((sponseesData) {
      setState(() {
        sponsees = sponseesData;
        filteredSponsees = sponsees;
      });
    });
  }

  Stream<List<Map<String, dynamic>>> fetchSponsors() {
    DatabaseReference sponRef = _database.child('Sponsors');
    return sponRef.onValue.map(
      (event) {
        List<Map<String, dynamic>> Sponsors = [];
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) async {
                if (value is Map<dynamic, dynamic>) {
                  Map<String, dynamic> data = {
                    'ID': key,
                    'Name': value['Name'] ?? '',
                    'Email': value['Email'] ?? '',
                    'Bio': value['Bio'] ?? '',
                    'Picture': value['Picture'],
                    'Type': 'Sponsor',
                  };
                  if (user?.uid != data['ID']) Sponsors.add(data);
                }
              });
            }
          }
        } catch (e) {
          print('Error occurred: $e');
        }
        print(Sponsors);
        return Sponsors;
      },
    );
  }

  Stream<List<Map<String, dynamic>>> fetchSponsees() {
    DatabaseReference sponRef = _database.child('Sponsees');
    return sponRef.onValue.map(
      (event) {
        List<Map<String, dynamic>> Sponsees = [];
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) async {
                if (value is Map<dynamic, dynamic>) {
                  Map<String, dynamic> data = {
                    'ID': key,
                    'Name': value['Name'] ?? '',
                    'Email': value['Email'] ?? '',
                    'Bio': value['Bio'] ?? '',
                    'Picture': value['Picture'],
                    'Type': 'Sponsee',
                  };
                  if (user?.uid != data['ID']) Sponsees.add(data);
                }
              });
            }
          }
        } catch (e) {
          print('Error occurred: $e');
        }
        return Sponsees;
      },
    );
  }

  void filterUsers(String text) {
    text = text.trim();

    setState(() {
      filteredSponsors = Sponsors.where((user) =>
              user['Name']?.toLowerCase().contains(text.toLowerCase()) == true)
          .toList();

      filteredSponsees = sponsees
          .where((user) =>
              user['Name']?.toLowerCase().contains(text.toLowerCase()) == true)
          .toList();
    });
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
          int displayCount = allSponsors.length < 15 ? allSponsors.length : 15;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 51, 45, 81),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 33),
                  Center(
                    child: Container(
                      width: 430,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(96, 158, 158, 158),
                            offset: Offset(0, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.search, color: Colors.grey),
                            onPressed: () {
                              setState(() {});
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search for a user',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              onChanged: (text) {
                                filterUsers(text);
                              },
                              onEditingComplete: () {
                                String trimmedText =
                                    searchController.text.trim();
                                searchController.text = trimmedText;
                                searched = trimmedText;
                                filterUsers(trimmedText);
                              },
                            ),
                          ),
                          if (searchController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.grey),
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
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
                    height: 70.0,
                  ),
                ),
              ],
            ),
            if (searched.isNotEmpty)
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Search results for user",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Color.fromARGB(255, 91, 79, 158),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight - 1000,
                      child: Scrollbar(
                        child: ListView(
                          children: [
                            _buildUserList(context, filteredSponsors,
                                filteredSponsees, searchController.text),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
            const SizedBox(height: 20),
            if (sponsors.isEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.3),
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
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 9,
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
                      }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(
    BuildContext context,
    List<Map<String, dynamic>> sponsors,
    List<Map<String, dynamic>> sponsees,
    String searchQuery,
  ) {
    if (sponsors.isEmpty && sponsees.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No users that matched $searchQuery',
            style: TextStyle(
              fontSize: 24,
              color: Color.fromARGB(255, 189, 189, 189),
            ),
          ),
          /*  TextButton(
          child: Text(
            "Go Back",
            style: TextStyle(
              fontSize: 23,
              decoration: TextDecoration.underline,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ), */
        ],
      );
    }

    return Column(
      children: [
        _buildUserCategory(context, 'Sponsors', sponsors, searchQuery),
        _buildUserCategory(context, 'Sponsees', sponsees, searchQuery),
      ],
    );
  }

  Widget _buildUserCategory(BuildContext context, String category,
      List<Map<String, dynamic>> users, String text) {
    if (users == null || users.isEmpty) {
      return SizedBox.shrink();
    }

    if (text.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Text(
              category,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 51, 45, 81),
              ),
            ),*/
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: users.map((user) {
                String id = user['ID'] ?? 'No ID available';
                String name = user['Name'] ?? 'No name available';
                String pic = user['Picture'] ?? '';
                String bio = user['Bio'] ?? 'no bio available';
                String type = user['Type'] ?? '';

                return Card(
                  color: Color.fromARGB(255, 255, 255, 255),
                  child: ListTile(
                    title: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(pic),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: Color.fromARGB(255, 51, 45, 81),
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(
                                height:
                                    4), // Add some space between name and bio
                            Text(
                              type,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 51, 45, 81),
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(
                                height:
                                    4), // Add some space between name and bio
                            Text(
                              bio.length > 65
                                  ? '${bio.substring(0, 65)}...'
                                  : bio,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 51, 45, 81),
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert),
                      color: Color.fromARGB(255, 91, 79, 158),
                      onPressed: () {
                        String userType =
                            (type == 'Sponsee') ? 'Sponsees' : 'Sponsors';

                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ViewOthersProfile(userType, id),
                        ));
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    // Return a default widget if the search input is empty
    return Text(
      '',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
    );
  }
}
