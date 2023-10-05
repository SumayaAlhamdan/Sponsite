import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sponsite/screens/chat_service.dart';
import 'package:sponsite/screens/createGoogleCalendarEvent.dart';
import 'package:sponsite/screens/view_others_profile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../FirebaseApi.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String receiverUserName;
  final String? pic;

  const ChatPage({
    Key? key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.receiverUserName,
    this.pic,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService chatService = ChatService();
  String senderPic = 'assets/placeholder_image.png';

  @override
  void initState() {
    super.initState();
  }

  Future<String?> downloadFile(String fileName) async {
    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('chatsFile/$fileName');
      final String downloadURL = await storageRef.getDownloadURL();
      print(downloadURL);
      return downloadURL;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  void sendFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) {
      return;
    }

    final path = result.files.single.path;

    if (path == null) {
      return;
    }

    final fileName = basename(path);
    final destination = 'chatsFile/$fileName';

    final uploadTask = FirebaseApi.uploadFile(destination, File(path));
    chatService.sendFile(widget.receiverUserID, result);
    uploadTask?.snapshotEvents.listen((TaskSnapshot snapshot) {
      if (snapshot.state == TaskState.success) {
        final urlDownload = snapshot.ref.getDownloadURL();
        print('Download-Link: $urlDownload');
      } else if (snapshot.state == TaskState.error) {
        print('File upload failed: ${TaskState.error}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 51, 45, 81),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        )),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context)
                .pop(); // Navigate back when the back button is pressed
          },
        ),
        title: Row(
          children: [
            SizedBox(width: 8.0),
            Image.network(
              widget.pic ?? senderPic,
              width: 50,
              height: 50,
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
            SizedBox(width: 8.0),
            Text(
              widget.receiverUserName,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 50,
            ),
            onSelected: (value) {
              // Handle menu item selection here
              switch (value) {
                case 'Profile':
// Initialize the Realtime Database reference
                  final DatabaseReference databaseReference =
                      FirebaseDatabase.instance.reference();

// Replace "currentUserId" with the ID of the current user
                  String currentUserId = chatService.currentUserId;

// Fetch sponsors
                  databaseReference.child("Sponsors").onValue.listen((event) {
                    if (event.snapshot.value != null) {
                      Map<dynamic, dynamic> sponsorsData =
                          event.snapshot.value as Map<dynamic, dynamic>;

                      if (sponsorsData != null &&
                          sponsorsData.containsKey(currentUserId)) {
                        // The current user is a sponsor, navigate to the sponsor's profile
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ViewOthersProfile(
                                "Sponsees", widget.receiverUserID),
                          ),
                        );
                        return;
                      }
                    }
                  });
                  databaseReference.child("Sponsees").onValue.listen((event) {
                    if (event.snapshot.value != null) {
                      Map<dynamic, dynamic> sponseesData =
                          event.snapshot.value as Map<dynamic, dynamic>;

                      if (sponseesData != null &&
                          sponseesData.containsKey(currentUserId)) {
                        // The current user is a sponsor, navigate to the sponsor's profile
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ViewOthersProfile(
                                "Sponsors", widget.receiverUserID),
                          ),
                        );
                        return;
                      }
                    }
                  });
                  break;
                case 'Meeting':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => createEvent(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Profile',
                  child: ListTile(
                    leading: Icon(
                      Icons.perm_identity,
                      size: 30,
                    ),
                    title: Text(
                      'Profile',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Meeting',
                  child: ListTile(
                    leading: Icon(
                      Icons.video_call,
                      size: 30,
                    ),
                    title: Text(
                      'Schedule Meeting',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: chatService.getMsgAndFile(
                chatService.currentUserId,
                widget.receiverUserID,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> messagesAndFiles = snapshot.data!;
                  messagesAndFiles.sort((a, b) {
                    final int timestampA = a['data']['timestamp'];
                    final int timestampB = b['data']['timestamp'];

                    final DateTime dateTimeA =
                        DateTime.fromMillisecondsSinceEpoch(timestampA);
                    final DateTime dateTimeB =
                        DateTime.fromMillisecondsSinceEpoch(timestampB);

                    return dateTimeA.compareTo(dateTimeB);
                  });

                  return ListView.builder(
                    itemCount: messagesAndFiles.length,
                    itemBuilder: (context, index) {
                      final chatItem = messagesAndFiles[index];

                      final type = chatItem['type'] as String;
                      final data = chatItem['data'] as Map<String, dynamic>;
                      final isCurrentUser =
                          data['senderID'] == chatService.currentUserId;

                      if (type == 'MessageType.Message') {
                        final message = data['msg'] as String;
                        return ListTile(
                          title: Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.grey
                                    : Color.fromARGB(255, 51, 45, 81),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (type == 'MessageType.File') {
                        final fileName = data['fileName'] as String;
                        return ListTile(
                          title: Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () async {
                                String? downloadURL =
                                    await downloadFile(fileName);
                                if (downloadURL != null) {
                                  launchUrl(Uri.parse(downloadURL));
                                } else {
                                  // Handle the case where an error occurred during the download
                                }
                              },
                              child: Text(
                                fileName,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue,
                                  decorationThickness:
                                      2.0, // Customize the thickness if needed
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    child: TextField(
                      style: TextStyle(fontSize: 20),
                      controller: _messageController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(
                                  255, 51, 45, 81)), // Set the border color
                          borderRadius:
                              BorderRadius.circular(10.0), // Set border radius
                        ),
                        hintText: "Type your message...",
                        hintStyle: TextStyle(
                            color: Color.fromARGB(
                                255, 51, 45, 81)), // Change hint text color
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendFile(); // Call sendFile function to send a file
                  },
                  icon: Icon(Icons.attach_file_rounded,
                      color: Color.fromARGB(255, 51, 45, 81)),
                  iconSize: 25,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 51, 45, 81),
                    size: 25,
                  ),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      chatService.sendMsg(
                        widget.receiverUserID,
                        message,
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
