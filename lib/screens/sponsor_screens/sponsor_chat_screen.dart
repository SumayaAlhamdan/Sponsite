import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sponsite/screens/chatPage.dart';

class SponsorChat extends StatefulWidget {
  const SponsorChat({Key? key}) : super(key: key);

  @override
  _SponsorChatState createState() => _SponsorChatState();
}

class _SponsorChatState extends State<SponsorChat> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: TextStyle(
            color: Color.fromARGB(255, 51, 45, 81),
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
      ),
      body: buildUserList(),
    );
  }

  Widget buildUserList() {
    // Replace 'your_sponsor_id' with the ID of the current sponsor
    String currentSponsorId = auth.currentUser!.uid;
    print('HERE SPONSOR ID');
    print(currentSponsorId);

    return StreamBuilder(
      stream: _database
          .child('offers')
          .orderByChild('sponsorId')
          .equalTo(currentSponsorId)
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('ERROR');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return Text('No data available');
        }

        Map<dynamic, dynamic> offerData =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<MapEntry<dynamic, dynamic>> offers = offerData.entries.toList();

        // Extract sponsee IDs from the offers and check if they are still active
        List<String> activeSponseeIds = [];
        Set<String> uniqueSponseeIds = Set<String>(); // To ensure uniqueness
        // Get the current Unix timestamp
        DateTime currentTimestamp = DateTime.now();

        for (var entry in offers) {
          Map<dynamic, dynamic> data = entry.value as Map<dynamic, dynamic>;
          String sponseeId = data['sponseeId'] ?? '';
          String offerTimestampStr = data['TimeStamp'] ?? '0';
          DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS");
          DateTime offerDateTime = dateFormat.parse(offerTimestampStr);

          // Check if the offer is active based on the timestamp
          if (offerDateTime.isBefore(currentTimestamp) &&
              !uniqueSponseeIds.contains(sponseeId)) {
            activeSponseeIds.add(sponseeId);
            uniqueSponseeIds.add(sponseeId);
          }
        }

        return ListView.builder(
          itemCount: activeSponseeIds.length,
          itemBuilder: (context, index) {
            String sponseeId = activeSponseeIds[index];
            // Use sponseeId to fetch sponsee details from your 'Sponsees' node
            // Then, build and return a list item for each sponsee
            return FutureBuilder<Map<dynamic, dynamic>>(
              future: _fetchSponseeDetails(sponseeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    Map<dynamic, dynamic> sponseeData = snapshot.data!;
                    return buildUserListItem(sponseeId, sponseeData);
                  }
                }
                return SizedBox(); // Return an empty widget while loading
              },
            );
          },
        );
      },
    );
  }

  Future<Map<dynamic, dynamic>> _fetchSponseeDetails(String sponseeId) async {
    DatabaseReference sponseeRef = _database.child('Sponsees').child(sponseeId);

    return sponseeRef.onValue.map((event) {
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;
        if (dataMap != null) {
          return dataMap;
        }
      }

      print('Snapshot or data is null for sponseeId: $sponseeId');
      return {}; // Return an empty map or handle it differently based on your needs
    }).first; // Listen for the first event and then cancel the stream
  }

  Widget buildUserListItem(String key, Map<dynamic, dynamic> data) {
    String name = data['Name'] ?? 'No name available';
    String email = data['Email'] ?? 'No email available';
    String pic = data['Picture'] ?? 'No picture available';
    return Card(
      color: Color.fromARGB(255, 51, 45, 81),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(pic),
            backgroundColor: Colors.transparent,
            child: Image.network(
              pic,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/placeholder_image.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          email,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: email,
                receiverUserID: key, // Pass the clicked user's ID here
                receiverUserName: name,
                pic: pic,
              ),
            ),
          );
        },
      ),
    );
  }
}





// Make sure to initialize Firebase in your app (main.dart or appropriate location):
// Firebase.initializeApp();

/* void main() {
  runApp(MaterialApp(
    home: SponsorChat(),
  ));
} */

