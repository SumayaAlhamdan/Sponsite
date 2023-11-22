import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sponsite/screens/view_others_profile.dart';
import 'package:string_similarity/string_similarity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    runApp(MaterialApp(
      home: SearchForUsers(),
    ));
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Handle the error as needed
  }
}

class SearchForUsers extends StatefulWidget {
  @override
  _SearchForUsersState createState() => _SearchForUsersState();
}

class _SearchForUsersState extends State<SearchForUsers> {
  List<Map<String, dynamic>> sponsors = [];
  List<Map<String, dynamic>> sponsees = [];
  List<Map<String, dynamic>> filteredSponsors = [];
  List<Map<String, dynamic>> filteredSponsees = [];
  TextEditingController searchController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchSponsors().listen((sponsorsData) {
      setState(() {
        sponsors = sponsorsData;
        filteredSponsors = sponsors;
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
      filteredSponsors = sponsors
          .where((user) =>
              user['Name']?.toLowerCase().contains(text.toLowerCase()) == true)
          .toList();

      filteredSponsees = sponsees
          .where((user) =>
              user['Name']?.toLowerCase().contains(text.toLowerCase()) == true)
          .toList();

      // Sort filtered users based on name similarity
      filteredSponsors.sort((a, b) => StringSimilarity.compareTwoStrings(
              b['Name'].toLowerCase(), text.toLowerCase())
          .compareTo(StringSimilarity.compareTwoStrings(
              a['Name'].toLowerCase(), text.toLowerCase())));

      filteredSponsees.sort((a, b) => StringSimilarity.compareTwoStrings(
              b['Name'].toLowerCase(), text.toLowerCase())
          .compareTo(StringSimilarity.compareTwoStrings(
              a['Name'].toLowerCase(), text.toLowerCase())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('User Search'),
        backgroundColor: Color.fromARGB(255, 51, 45, 81), // Adjust as needed
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (text) {
                  filterUsers(text);
                },
                maxLength: 35, // Set the maximum number of characters
                decoration: InputDecoration(
                  labelText: 'Search Users',
                  counterText: '', // Remove the default character counter
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 51, 45, 81),
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  prefixIcon: Icon(Icons.search,
                      color: Color.fromARGB(255, 51, 45, 81)),
                  labelStyle: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
                ),
              ),
              _buildUserList(
                  filteredSponsors, filteredSponsees, searchController.text),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(
    List<Map<String, dynamic>> sponsors,
    List<Map<String, dynamic>> sponsees,
    String searchQuery,
  ) {
    if (sponsors.isEmpty && sponsees.isEmpty) {
      return Center(
        child: Text(
          'No users that matched $searchQuery',
          style: TextStyle(
            fontSize: 24,
            color: Color.fromARGB(255, 189, 189, 189),
          ),
        ),
      );
    }

    return Column(
      children: [
        /*  if (searchController.text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              "Search results for $searchQuery",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Color.fromARGB(255, 91, 79, 158),
              ),
            ),
          ), */
        _buildUserCategory('Sponsors', sponsors),
        _buildUserCategory('Sponsees', sponsees),
      ],
    );
  }

  Widget _buildUserCategory(String category, List<Map<String, dynamic>> users) {
    if (users == null || users.isEmpty) {
      return SizedBox.shrink();
    }

    if (searchController.text.isNotEmpty) {
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
                              bio.length > 75
                                  ? '${bio.substring(0, 75)}...'
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
