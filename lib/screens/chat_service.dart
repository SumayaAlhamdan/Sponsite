import 'dart:async';
import 'dart:io';

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
  final ChatItem? type;

  Msg({
    required this.receiverEmail,
    required this.receiverID,
    required this.senderEmail,
    required this.senderID,
    required this.msg,
    required this.timestamp,
    this.type,
  });

  Map<dynamic, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'receiverEmail': receiverEmail,
      'msg': msg,
      'timestamp': timestamp,
      'type': type?.type.toString(), // Convert the enum to a string
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
      type: map['type'] != null
          ? ChatItem(
              MessageType.values.firstWhere((e) => e.toString() == map['type']),
              map['msg'],
            )
          : null, // Parse the enum from the string
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
          'type': MessageType.File.toString(), // Store as a string
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
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) {
                if (value is Map<dynamic, dynamic>) {
                  final typeString = value['type'] as String;
                  // print('HERE TYPE TRING!!!!!!!!');
                  // print(typeString);
                  // final type = typeString == MessageType.Message.toString()
                  //     ? MessageType.Message
                  //     : MessageType.File;

                  Map<String, dynamic> data = {}; // Initialize data here

                  if (typeString == 'MessageType.Message') {
                    data = {
                      'receiverID': value['receiverID'] ?? '',
                      'receiverEmail': value['receiverEmail'] ?? '',
                      'senderID': value['senderID'] ?? '',
                      'senderEmail': value['senderEmail'] ?? '',
                      'msg': value['msg'] ?? '',
                      'timestamp': value['timestamp'] ?? ServerValue.timestamp,
                    };
                  } else if (typeString == 'MessageType.File') {
                    data = {
                      'senderID': value['senderID'] ?? '',
                      'receiverID': value['receiverID'] ?? '',
                      'fileName': value['fileName'] ?? '',
                      'timestamp': value['timestamp'] ?? ServerValue.timestamp,
                    };
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
      );

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
}
