import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
          'Chat', // The text content of the widget
          style: TextStyle(
              color: Colors.deepPurple, // Text color (deep purple)
              fontWeight: FontWeight.bold,
              fontSize: 40 // Text fontWeight (bold)
              ),
        ),
      ),
      body: buildUserList(),
    );
  }

  Widget buildUserList() {
    return StreamBuilder(
      stream: _database.child('Sponsees').onValue,
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

        Map<dynamic, dynamic> sponseeData =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<MapEntry<dynamic, dynamic>> sponsees =
            sponseeData.entries.toList();

        return ListView(
          children: sponsees.map((entry) {
            String key = entry.key.toString();
            Map<dynamic, dynamic> data = entry.value as Map<dynamic, dynamic>;
            return buildUserListItem(key, data);
          }).toList(),
        );
      },
    );
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
            backgroundImage:
                NetworkImage(pic), // Use the passed profile picture
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

