import 'package:flutter/material.dart';
import 'package:sponsite/screens/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String receiverUserName;

  const ChatPage({
    Key? key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.receiverUserName,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService chatService = ChatService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserName),
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
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              message.msg,
                              style: TextStyle(color: Colors.white),
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
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
