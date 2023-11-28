import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sponsite/screens/chatPage.dart';
import 'package:sponsite/screens/chat_service.dart';
import 'package:sponsite/widgets/customAppBar.dart';

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
     return Theme(
      // Apply your theme settings within the Theme widget
      data: ThemeData(
        // Set your desired font family or other theme configurations
        fontFamily: 'Urbanist',
        textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
        // Add other theme configurations here as needed
      ),
      ),
    child: Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(105), // Adjust the height as needed
        child: CustomAppBar(
          title: 'Chat',
        ),
      ),
      body: buildUserList(),
    )
    );
  }

  Widget buildUserList() {
    // Replace 'your_sponsor_id' with the ID of the current sponsor
    String currentSponsorId = auth.currentUser!.uid;
    ChatService chatService = ChatService();
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

        // Extract sponsee IDs from the offers and check if they are still active
        List<String> activeSponseeIds = [];
        Set<String> uniqueSponseeIds = Set<String>(); // To ensure uniqueness
        // Get the current Unix timestamp
        DateTime currentTimestamp = DateTime.now();

        for (var entry in offers) {
          Map<dynamic, dynamic> data = entry.value as Map<dynamic, dynamic>;
          String status = data['Status'] ?? '';
          String sponseeId = data['sponseeId'] ?? '';
          String offerTimestampStr = data['TimeStamp'] ?? '0';
          DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS");
          DateTime offerDateTime = dateFormat.parse(offerTimestampStr);

          // Check if the offer is active based on the timestamp
          if (status == 'Accepted' || status == 'Pending') {
            if (!uniqueSponseeIds.contains(sponseeId)) {
              activeSponseeIds.add(sponseeId);
              uniqueSponseeIds.add(sponseeId);
            }
          }
        }

        return ListView.builder(
          itemCount: activeSponseeIds.length,
          itemBuilder: (context, index) {
            String sponseeId = activeSponseeIds[index];
            ChatService chatService = ChatService();
            Stream<List<Map<String, dynamic>>> unreadMessages =
                chatService.getUnreadMsgs(currentSponsorId, sponseeId);
            int unreadCount =
                chatService.getUnreadMsgCount(unreadMessages, currentSponsorId);
            // Use sponseeId to fetch sponsee details from your 'Sponsees' node
            // Then, build and return a list item for each sponsee
            return FutureBuilder<Map<dynamic, dynamic>>(
              future: _fetchSponseeDetails(sponseeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    Map<dynamic, dynamic> sponseeData = snapshot.data!;
                    return buildUserListItem(
                        sponseeId, sponseeData, unreadCount);
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

  Widget buildUserListItem(
      String key, Map<dynamic, dynamic> data, int unreadCount) {
    String name = data['Name'] ?? 'No name available';
    String email = data['Email'] ?? 'No email available';
    String pic = data['Picture'] ?? 'No picture available';
    return Card(
      color: Color.fromARGB(255, 255, 255, 255),
      child: ListTile(
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
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
              color: Color.fromARGB(255, 51, 45, 81),
              fontSize: 25,
              fontWeight: FontWeight.w500
              //   fontWeight: unreadCount > 0 ? FontWeight.w900 : FontWeight.w500,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red, // Customize the color as needed
                    ),
                  )
                : SizedBox(width: 8), // Add some spacing between text and icon
            Icon(
              Icons.arrow_forward_ios_rounded,
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



// Make sure to initialize Firebase in your app (main.dart or appropriate location):
// Firebase.initializeApp();

/* void main() {
  runApp(MaterialApp(
    home: SponsorChat(),
  ));
} */

