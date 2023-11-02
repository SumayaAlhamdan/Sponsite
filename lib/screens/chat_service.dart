import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sponsite/FirebaseApi.dart'; // Make sure to import your FirebaseApi class here
import 'package:sponsite/local_notifications.dart';

class ChatItem {
  final MessageType type;
  final dynamic data;

  ChatItem(this.type, this.data);
}

enum MessageType { Message, File }

class Msg {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String receiverEmail;
  final dynamic msg;
  final dynamic timestamp;
  final ChatItem type;
  final bool isRead;

  Msg({
    required this.receiverEmail,
    required this.receiverID,
    required this.senderEmail,
    required this.senderID,
    required this.msg,
    required this.timestamp,
    required this.type,
    required this.isRead,
  });

  Map<dynamic, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'receiverEmail': receiverEmail,
      'msg': msg,
      'timestamp': timestamp,
      'type': type.type.toString(),
      'isRead': isRead, // Store isRead as a bool
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
      type: map['type'],
      isRead: map['isRead'] ?? false, // Parse the isRead property
    );
  }
}

class ChatService extends ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> messagesAndFiles = [];

  String get currentUserId {
    final User? currentUser = auth.currentUser;
    return currentUser?.uid ?? '';
  }

  Future<void> sendFile(String receiverID, FilePickerResult? file) async {
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      final String currentUserId = currentUser.uid;

      List<String> ids = [receiverID, currentUserId];
      ids.sort();
      String chatRoomID = ids.join('_');

      try {
        if (file == null) {
          return;
        }

        final fileName = basename(file.files.single.path!);

        final Map<String, dynamic> fileData = {
          'senderID': currentUserId,
          'receiverID': receiverID,
          'fileName': fileName,
          'timestamp': ServerValue.timestamp,
          'type': MessageType.File.toString(),
          'isRead': false,
        };

        await _database
            .child('chatrooms')
            .child(chatRoomID)
            .child('messages')
            .push()
            .set(fileData);

        // Handle file upload to Firebase Storage here if needed
        // FirebaseApi.uploadFile(destination, File(file.files.single.path!));
      } catch (error) {
        print('Error sending file: $error');
      }
    }
  }

  int getUnreadMsgCount(
      Stream<List<Map<String, dynamic>>> unreadMessages, String key) {
    int unreadCount = 0;

    unreadMessages.listen((messages) {
      for (var message in messages) {
        if (message['data']['receiverID'] == key &&
            !message['data']['isRead']) {
          unreadCount++;
          print('HEREEEEEE inside loop');
          print(unreadCount);
        }
        print('HEREEEEEE outside loop');
        print(unreadCount);
      }
    });
    print('HEREEEEEE unreadcount');
    print(unreadCount);
    return unreadCount;
  }

  Stream<List<Map<String, dynamic>>> getUnreadMsgs(
      String currentUserId, String receiverID) {
    List<String> ids = [receiverID, currentUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    DatabaseReference chatroomRef =
        _database.child('chatrooms').child(chatRoomID);

    return chatroomRef.child('messages').onValue.map(
      (event) {
        List<Map<String, dynamic>> unreadMessages = [];
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) {
                if (value is Map<dynamic, dynamic>) {
                  final typeString = value['type'] as String;

                  Map<String, dynamic> data = {}; // Initialize data here

                  if (typeString == MessageType.Message.toString()) {
                    data = {
                      'receiverID': value['receiverID'] ?? '',
                      'receiverEmail': value['receiverEmail'] ?? '',
                      'senderID': value['senderID'] ?? '',
                      'senderEmail': value['senderEmail'] ?? '',
                      'msg': value['msg'] ?? '',
                      'timestamp': value['timestamp'] ?? ServerValue.timestamp,
                      'isRead':
                          value['isRead'] ?? false, // Parse the isRead property
                    };
                  } else if (typeString == MessageType.File.toString()) {
                    data = {
                      'senderID': value['senderID'] ?? '',
                      'receiverID': value['receiverID'] ?? '',
                      'fileName': value['fileName'] ?? '',
                      'timestamp': value['timestamp'] ?? ServerValue.timestamp,
                      'isRead':
                          value['isRead'] ?? false, // Parse the isRead property
                    };
                  }

                  if (!data['isRead']) {
                    unreadMessages.add({
                      'type': typeString, // Store type as a string
                      'data': data,
                    });
                  }
                }
              });
            }
          }
        } catch (e) {
          print('Error occurred: $e');
          // Handle the error as needed, e.g., log it or return an error message.
        }

        return unreadMessages;
      },
    );
  }

  Future<void> deleteChatRoom(String currentUserId, String receiverID) async {
    try {
      List<String> ids = [receiverID, currentUserId];
      ids.sort();
      String chatRoomID = ids.join('_');

      DatabaseReference chatroomRef =
          _database.child('chatrooms').child(chatRoomID);

      // Remove the chat room from the database
      await chatroomRef.remove();
    } catch (e) {
      // Handle any errors that occur during the deletion process
      print('Error deleting chat room: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getMsgAndFile(
    String currentUserId,
    String receiverID,
  ) {
    List<String> ids = [receiverID, currentUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    DatabaseReference chatroomRef =
        _database.child('chatrooms').child(chatRoomID);

    return chatroomRef.child('messages').onValue.map(
      (event) {
        List<Map<String, dynamic>> messagesAndFiles = [];
        List<Map<String, dynamic>> unreadMessages = [];
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) async {
                if (value is Map<dynamic, dynamic>) {
                  final typeString = value['type'] as String;

                  Map<String, dynamic> data = {}; // Initialize data here

                  if (typeString == MessageType.Message.toString()) {
                    data = {
                      'receiverID': value['receiverID'] ?? '',
                      'receiverEmail': value['receiverEmail'] ?? '',
                      'senderID': value['senderID'] ?? '',
                      'senderEmail': value['senderEmail'] ?? '',
                      'msg': value['msg'] ?? '',
                      'timestamp': value['timestamp'] ?? ServerValue.timestamp,
                      'isRead':
                          value['isRead'] ?? false, // Parse the isRead property
                    };
                  } else if (typeString == MessageType.File.toString()) {
                    data = {
                      'senderID': value['senderID'] ?? '',
                      'receiverID': value['receiverID'] ?? '',
                      'fileName': value['fileName'] ?? '',
                      'timestamp': value['timestamp'] ?? ServerValue.timestamp,
                      'isRead':
                          value['isRead'] ?? false, // Parse the isRead property
                    };

                    if (!data['isRead']) {
                      unreadMessages.add({
                        'type': typeString,
                        'data': data,
                      });
                    }
                  }

                  messagesAndFiles.add({
                    'type': typeString, // Store type as a string
                    'data': data,
                  });
                }
              });
            }
          }
        } catch (e) {
          print('Error occurred: $e');
          // Handle the error as needed, e.g., log it or return an error message.
        }

        print('IM HEREEEE NEW');
        print(messagesAndFiles);
        return messagesAndFiles;
      },
    );
  }

  Future<void> sendMsg(String receiverID, String msg) async {
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      final String currentUserId = currentUser.uid;
      final String currentUserEmail = currentUser.email ?? '';

      List<String> ids = [receiverID, currentUserId];
      ids.sort();
      String chatRoomID = ids.join('_');

      final Msg newMsg = Msg(
        receiverID: receiverID,
        receiverEmail: '',
        senderID: currentUserId,
        senderEmail: currentUserEmail,
        msg: msg,
        timestamp: ServerValue.timestamp,
        type: ChatItem(
          MessageType.Message,
          msg,
        ),
        isRead: false,
      );

      await _database
          .child('chatrooms')
          .child(chatRoomID)
          .child('messages')
          .push()
          .set(newMsg.toMap());

      final recieverToken = await _retrieverecieverToken(receiverID);
            sendNotificationToreciever1(recieverToken! , msg);
    }
  }
  Future<void> sendNotificationToreciever1(String recieverToken , String msg) async {
    final String serverKey =
        'AAAAw5lT-Yg:APA91bE4EbR1XYHUoMl-qZYAFVsrtCtcznSsh7RSCSZ-yJKR2_bdX8f9bIaQgDrZlEaEaYQlEpsdN6B6ccEj5qStijSCDN_i0szRxhap-vD8fINcJAA-nK11z7WPzdZ53EhbYF5cp-ql'; //
    final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> notification = {
      'body': 'Name: $msg',
      'title': 'New Message',
      'sound': 'default',
    };

    final Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'notif_type': 'status'
      // Add any additional data you want to send
    };

    final Map<String, dynamic> body = {
      'notification': notification,
      'data': data,
      'to': recieverToken, // The FCM token of the service provider
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print(
            'Error sending notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
   Future<String?> _retrieverecieverToken(String id) async {
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference();
    final DataSnapshot dataSnapshot =
        (await databaseReference.child('userTokens').child(id).once()).snapshot;
    final Map<dynamic, dynamic>? data =
        dataSnapshot.value as Map<dynamic, dynamic>?;
    if (data != null && data.containsKey('token')) {
      return data['token'].toString();
    }

    return null;
  }
}
