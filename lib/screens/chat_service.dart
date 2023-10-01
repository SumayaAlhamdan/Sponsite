import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/local_notifications.dart';

class Msg {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String receiverEmail;
  final String msg;
  final dynamic timestamp; // Dynamic type for Firebase timestamp

  Msg({
    required this.receiverEmail,
    required this.receiverID,
    required this.senderEmail,
    required this.senderID,
    required this.msg,
    required this.timestamp,
  });

  Map<dynamic, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'receiverEmail': receiverEmail,
      'msg': msg,
      'timestamp': timestamp, // Use the provided timestamp
    };
  }

  factory Msg.fromMap(Map<dynamic, dynamic> map) {
    return Msg(
      receiverEmail: map['receiverEmail'] ?? '',
      receiverID: map['receiverID'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      senderID: map['senderID'] ?? '',
      msg: map['msg'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }
}

class ChatService extends ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  String get currentUserId {
    final User? currentUser = auth.currentUser;
    return currentUser?.uid ?? '';
  }

  Future<void> sendMsg(String receiverID, String msg) async {
    // Get the current user
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      // Get the current user's ID and email
      final String currentUserId = currentUser.uid;
      final String currentUserEmail = currentUser.email ?? '';

      // Determine the room ID (you can customize how you create this)
      List<String> ids = [receiverID, currentUserId];
      ids.sort();
      String chatRoomID = ids.join('_');

      // Create a new message with the current timestamp
      final Msg newMsg = Msg(
        receiverID: receiverID,
        receiverEmail: '', // You can set this to receiver's email if needed
        senderID: currentUserId,
        senderEmail: currentUserEmail,
        msg: msg,
        timestamp: ServerValue.timestamp,
      );

      // Add the message to the database
      await _database
          .child('chatrooms')
          .child(chatRoomID)
          .child('messages')
          .push()
          .set(newMsg.toMap());
            if (currentUserId == receiverID) {
        // Modify this part to use your notification service
        NotificationService().showNotification(
          title: 'New Message',
          body: 'You have received a new message.',
        );
      }
    }
  }

  Stream<List<Msg>> getMsg(String currentUserId, String receiverID) {
    // Determine the room ID (you can customize how you create this)
    List<String> ids = [receiverID, currentUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    DatabaseReference messagesRef =
        _database.child('chatrooms').child(chatRoomID).child('messages');

    // Listen for changes in the messages reference and order them by timestamp
    return messagesRef.orderByChild('timestamp').onValue.map((event) {
      List<Msg> messages = [];

      DataSnapshot dataSnapshot = event.snapshot;

      final dynamic messagesData = dataSnapshot.value;

      if (messagesData is Map<dynamic, dynamic>) {
        messagesData.forEach((key, value) {
          messages.add(Msg.fromMap(value));
        });
      }

      return messages;
    });
  }
}
