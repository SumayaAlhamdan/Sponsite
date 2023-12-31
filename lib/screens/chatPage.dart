import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sponsite/screens/chat_service.dart';
import 'package:sponsite/screens/createGoogleEvent.dart';
import 'package:sponsite/screens/view_others_profile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../FirebaseApi.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String receiverUserName;
  final String pic;

  const ChatPage({
    Key? key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.receiverUserName,
    required this.pic,
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
     return Theme(
      // Apply your theme settings within the Theme widget
      data: ThemeData(
        // Set your desired font family or other theme configurations
        textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',

      ),
        // Add other theme configurations here as needed
      ),
      ),
    child:
     Scaffold(
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
            GestureDetector(
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.pic),
                backgroundColor: Colors
                    .transparent, // Optional, set a background color if needed
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle the error by returning a placeholder image
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(
                        'assets/placeholder_image.png'), // Placeholder image asset
                    backgroundColor: Colors.transparent,
                  );
                },
              ),
              onTap: () {
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
              },
            ),
            SizedBox(width: 8.0),
            GestureDetector(
              child: Text(
                widget.receiverUserName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              onTap: () {
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
              },
            )
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 40,
            ),
            onSelected: (value) {
              // Handle menu item selection here
              switch (value) {
                case 'DeleteChat':
                  chatService.deleteChatRoom(chatService.currentUserId,
                      widget.receiverUserID); // needssssssssss fixing
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
                  value:
                      'DeleteChat', // Add a unique value for the delete option
                  child: ListTile(
                    leading: Icon(
                      Icons.delete,
                      size: 25,
                    ),
                    title: Text(
                      'Delete Chat',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Meeting',
                  child: ListTile(
                    leading: Icon(
                      Icons.video_call,
                      size: 25,
                    ),
                    title: Text(
                      'Schedule Meeting',
                      style: TextStyle(fontSize: 14),
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

                  if (messagesAndFiles.isEmpty) {
                    // Render an empty chat message
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/Pack.png', // Specify the asset path
                            width: 200, // Specify the width of the image
                            height: 200, // Specify the height of the image
                          ),
                          Text('There are no messages in this chat yet', ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: messagesAndFiles.length,
                    itemBuilder: (context, index) {
                      final chatItem = messagesAndFiles[index];

                      final type = chatItem['type'] as String;
                      final data = chatItem['data'] as Map<String, dynamic>;
                      final timestampMillis = data['timestamp']
                          as int; // Assuming the timestamp is in milliseconds
                      final timestamp =
                          DateTime.fromMillisecondsSinceEpoch(timestampMillis);
                      final formattedTimestamp =
                          DateFormat('HH:mm:ss, MMM d, y').format(
                              timestamp); // Customize the format as needed
                      final isCurrentUser =
                          data['senderID'] == chatService.currentUserId;

                      if (type == 'MessageType.Message') {
                        final message = data['msg'] as String;
                        return Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? const Color.fromARGB(255, 228, 227, 227)
                                    : Color.fromARGB(255, 51, 45, 81),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? Color.fromARGB(255, 51, 45, 81)
                                      : const Color.fromARGB(
                                          255, 228, 227, 227),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              formattedTimestamp,
                              style: TextStyle(
                                fontSize: 12, // Adjust the font size as needed
                                color: Colors
                                    .grey, // Set the color of the timestamp
                              ),
                            ),
                          ],
                        );
                      } else if (type == 'MessageType.File') {
                        final fileName = data['fileName'] as String;
                        return Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                String? downloadURL =
                                    await downloadFile(fileName);
                                if (downloadURL != null) {
                                  launchUrl(Uri.parse(downloadURL));
                                } else {
                                  // Handle the case where an error occurred during the download
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Color.fromARGB(255, 228, 227, 227)
                                      : Color.fromARGB(255, 51, 45, 81),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  fileName,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                    decorationThickness: 2.0,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              formattedTimestamp,
                              style: TextStyle(
                                fontSize: 12, // Adjust the font size as needed
                                color: Colors
                                    .grey, // Set the color of the timestamp
                              ),
                            ),
                          ],
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
                      maxLength: 2000,
                      maxLines:
                          null, // Set the maximum length of characters here (2000 in this case)
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
                                255, 51, 45, 81),
                    ), // Change hint text color
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
    )
     );
  }
}
