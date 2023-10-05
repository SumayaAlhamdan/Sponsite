import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/chatPage.dart';

class SponseeChat extends StatefulWidget {
  const SponseeChat({Key? key}) : super(key: key);

  @override
  _SponseeChatState createState() => _SponseeChatState();
}

class _SponseeChatState extends State<SponseeChat> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
      ),
      body: buildUserList(),
    );
  }

  Widget buildUserList() {
    // Replace 'your_sponsee_id' with the ID of the current sponsee
    String currentSponseeId = auth.currentUser!.uid;

    return StreamBuilder(
      stream: _database
          .child('offers')
          .orderByChild('sponseeId')
          .equalTo(currentSponseeId)
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

        // Extract sponsor IDs from the offers
        List sponsorIds = offers.map((entry) {
          Map<dynamic, dynamic> data = entry.value as Map<dynamic, dynamic>;
          return data['sponsorId'] ?? '';
        }).toList();

        return ListView.builder(
          itemCount: sponsorIds.length,
          itemBuilder: (context, index) {
            String sponsorId = sponsorIds[index];
            // Use sponsorId to fetch sponsor details from your 'Sponsors' node
            // Then, build and return a list item for each sponsor
            return FutureBuilder<Map<dynamic, dynamic>>(
              future: _fetchSponsorDetails(sponsorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    Map<dynamic, dynamic> sponsorData = snapshot.data!;
                    return buildUserListItem(sponsorId, sponsorData);
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

  Future<Map<dynamic, dynamic>> _fetchSponsorDetails(String sponsorId) async {
    DatabaseReference sponsorRef = _database.child('Sponsors').child(sponsorId);

    return sponsorRef.onValue.map((event) {
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;
        if (dataMap != null) {
          return dataMap;
        }
      }

      print('Snapshot or data is null for sponsorId: $sponsorId');
      return {}; // Return an empty map or handle it differently based on your needs
    }).first; // Listen for the first event and then cancel the stream
  }

  Widget buildUserListItem(String key, Map<dynamic, dynamic> data) {
    String name = data['Name'] ?? 'No name available';
    String email = data['Email'] ?? 'No email available';
    String pic = data['Picture'] ?? 'No picture available';
    return Card(
      color: Colors.deepPurple,
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
