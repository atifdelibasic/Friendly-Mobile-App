import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:provider/provider.dart';
import '../domain/user.dart';
import '../providers/user_provider.dart';
import '../services/signalr_service.dart';
import '../utility/app_url.dart';

class ChatScreen extends StatefulWidget {
  final int recipientId;
  final String recipientProfileImage;
  final String? fullName;

  ChatScreen({ required this.recipientId, required this.recipientProfileImage, required this.fullName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SignalRService _signalRService = SignalRService();
  List<Map<String, dynamic>> _messages = [];
   
  @override
  void initState() {
    super.initState();
    initializeToken();
  }

  void initializeToken() async {
    var token = await UserPreferences().getToken();
    _signalRService.connect('${AppUrl.baseUrl}/example?recipient_id=${widget.recipientId}', token);

    // Set up the message listener
    _signalRService.onReceiveMessage((message, isMe) {
      setState(() {
        // Add the new message to the beginning of the list
        _messages.insert(0, {'message': message, 'isMe': isMe});
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    User? user = Provider.of<UserProvider>(context).user;
    print("user");
    print(widget.recipientProfileImage);
    
    return Scaffold(
    appBar: AppBar(
  title: Row(
    children: [
      // Image
      CircleAvatar(
        backgroundImage: NetworkImage(widget.recipientProfileImage), // Provide the image URL here
        radius: 16,
      ),
      SizedBox(width: 8), // Adjust the width as needed for spacing
      // Title Text
      Text(widget.fullName ?? ""),
    ],
  ),
),
      body: Column(
        children: [
         Expanded(
  child: _messages.isEmpty
    ? Center(
        child: Text(
          'Start conversation with ${widget.fullName}',
          style: TextStyle(fontSize: 18),
        ),
      )
    : ListView.builder(
        reverse: true, // Reverse the list
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              if (!message['isMe'])
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    // Assuming user profile image is provided in the message data
                    backgroundImage: NetworkImage(widget.recipientProfileImage),
                    radius: 20,
                  ),
                ),
              // Message content
              Expanded(
                child: Align(
                  alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: message['isMe'] ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      message['message'],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
),


          // Message input field and send button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(labelText: 'Type your message...'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  // Send message when the send button is pressed
                  await _signalRService.sendMessage(_messageController.text);
                  _messageController.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Disconnect from SignalR when the screen is disposed
    print("connection disposed");
    _signalRService.disconnect();
    super.dispose();
  }
}
