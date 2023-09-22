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
        title: Text('Chat'),
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

    return ListTile(
      title: Text(name),
      subtitle: Text(email),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverUserEmail: email,
              receiverUserID: key, // Pass the clicked user's ID here
              receiverUserName: name,
            ),
          ),
        );
      },
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
