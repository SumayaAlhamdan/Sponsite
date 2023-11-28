import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sponsite/screens/chatPage.dart';
import 'package:sponsite/screens/chat_service.dart';
import 'package:sponsite/widgets/customAppBar.dart';


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
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(105), // Adjust the height as needed
        child: CustomAppBar(
          title: 'Chat',
        ),
      ),
      body: buildUserList(),
    );
  }

  Widget buildUserList() {
    // Replace 'your_sponsee_id' with the ID of the current sponsee
    String currentSponseeId = auth.currentUser!.uid;
    // Create an instance of ChatService

    print('HERE SPONSEE ID');
    print(currentSponseeId);

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
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/Edit.png'),
                SizedBox(height: 20),
                Text(
                  'No chatrooms available',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 189, 189, 189),
                  ),
                ),
              ],
            ),
          );
        }

        Map<dynamic, dynamic> offerData =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<MapEntry<dynamic, dynamic>> offers = offerData.entries.toList();

        // Extract sponsor IDs from the offers and check if they are still active
        List<String> activeSponsorIds = [];
        Set<String> uniqueSponsorIds = Set<String>(); // To ensure uniqueness
        // Get the current Unix timestamp
        DateTime currentTimestamp = DateTime.now();

        for (var entry in offers) {
          Map<dynamic, dynamic> data = entry.value as Map<dynamic, dynamic>;
          String status = data['Status'] ?? '';
          String sponsorId = data['sponsorId'] ?? '';
          String offerTimestampStr = data['TimeStamp'] ?? '0';
          DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS");
          DateTime OFFERdateTime = dateFormat.parse(offerTimestampStr);
          // Get the current Unix timestamp
          int currentTimestampINT = DateTime.now().millisecondsSinceEpoch;
          //   print('IM HEREEEE');
          //  print(sponsorId);
          // print(offerTimestampStr);
          // print(currentTimestamp);
          // print(OFFERdateTime);
          // Check if the offer is active based on the timestamp
          if (status == 'Accepted' || status == 'Pending') {
            if (!uniqueSponsorIds.contains(sponsorId)) {
              activeSponsorIds.add(sponsorId);
              uniqueSponsorIds.add(sponsorId);
            }
          }
        }

        return ListView.builder(
          itemCount: activeSponsorIds.length,
          itemBuilder: (context, index) {
            String sponsorId = activeSponsorIds[index];
            ChatService chatService = ChatService();
            Stream<List<Map<String, dynamic>>> unreadMessages =
                chatService.getUnreadMsgs(currentSponseeId, sponsorId);
            int unreadCount =
                chatService.getUnreadMsgCount(unreadMessages, currentSponseeId);
            // Use sponsorId to fetch sponsor details from your 'Sponsors' node
            // Then, build and return a list item for each sponsor
            return FutureBuilder<Map<dynamic, dynamic>>(
              future: _fetchSponsorDetails(sponsorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    Map<dynamic, dynamic> sponsorData = snapshot.data!;
                    return buildUserListItem(
                        sponsorId, sponsorData, unreadCount);
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

  Widget buildUserListItem(
      String key, Map<dynamic, dynamic> data, int unreadCount) {
    //MAJD THE CARD STARTS HERE
    String name = data['Name'] ?? 'No name available';
    String email = data['Email'] ?? 'No email available';
    String pic = data['Picture'] ?? 'No picture available';
    return Card(
      color: Color.fromARGB(255, 255, 255, 255),
      child: ListTile(
        tileColor: Colors.white,
        leading: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage(pic), // Set the image as backgroundImage
                backgroundColor: Colors
                    .transparent, // Optional, set a background color if needed
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle the error by returning a placeholder image
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(
                        'assets/placeholder_image.png'), // Placeholder image asset
                    backgroundColor: Colors.transparent,
                  );
                },
              ),
            ],
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: Color.fromARGB(255, 51, 45, 81),
            fontSize: 25,
            fontWeight: unreadCount > 0 ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          email,
          style: const TextStyle(
            color: Color.fromARGB(255, 51, 45, 81),
            fontSize: 17,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            unreadCount > 0
                ? Text(
                    '$unreadCount unread massges',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red, // Customize the color as needed
                    ),
                  )
                : SizedBox(width: 8), // Add some spacing between text and icon
            Icon(
              Icons.arrow_forward_ios_rounded, // Add the arrow icon here
              color: Color.fromARGB(255, 51, 45, 81),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: email,
                receiverUserID: key,
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
