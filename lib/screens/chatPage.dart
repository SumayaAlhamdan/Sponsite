import 'package:flutter/material.dart';
import 'package:sponsite/screens/chat_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sponsite/screens/chatDetail.dart';


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
  String senderPic =
      'assets/placeholder_image.png'; // Default profile picture URL

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 8.0),
            Image.network(
              widget.pic ?? senderPic,
              width: 60, // Set the desired width
              height: 60, // Set the desired height
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
            SizedBox(width: 8.0), // Add some space between the image and text
            Text(
              widget.receiverUserName,
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
            icon: Icon(Icons.more_horiz, size: 50),// You can change the icon as needed
            onPressed: () {
              // Navigate to the chatDetails() page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>  MyApp(),
                ),
              );
            }
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Msg>>(
              stream: chatService.getMsg(
                chatService.currentUserId, // Current user's ID
                widget.receiverUserID, // Receiver's ID
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Msg> messages = snapshot.data!;

                  // Sort the messages by timestamp in ascending order
                  messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                  return ListView.builder(
                    reverse:
                        true, // Reverse the ListView to show messages in ascending order
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser =
                          message.senderID == widget.receiverUserID;

                      return ListTile(
                        title: Align(
                          alignment: isCurrentUser
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.grey
                                  : Colors.deepPurple,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Text(
                              message.msg,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                      );
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
                      style: TextStyle(fontSize: 25), // Set the font size here
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      // Send the message using the ChatService
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

