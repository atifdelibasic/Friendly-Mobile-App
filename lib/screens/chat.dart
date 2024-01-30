import 'package:flutter/material.dart';
import '../services/signalr_service.dart';

class ChatScreen extends StatefulWidget {
  final int senderId;
  final int recipientId;

  ChatScreen({required this.senderId, required this.recipientId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SignalRService _signalRService = SignalRService();

  @override
  void initState() {
    super.initState();

    // Connect to SignalR when the screen is initialized
     _signalRService.connect('https://localhost:7169/example?recipient_id=2', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImF0aWYuZGVsaWJhc2ljQGdtYWlsLmNvbSIsInVzZXJpZCI6IjEiLCJmaXJzdG5hbWUiOiJBdGlmIiwibGFzdG5hbWUiOiJEZWxpYmFzaWMiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiZXhwIjoxNzA2OTk1MTUzLCJpc3MiOiJodHRwOi8vZnJpZW5kbHkuYXBwIiwiYXVkIjoiaHR0cDovL2ZyZWluZGx5LmFwcCJ9.jd7fQy_HzLuuumG-JskP-rgA-VpqkH6mka8ex7F9bYc');
    
    // Set up the message listener
    _signalRService.onReceiveMessage((message, me) {
      print(message);
      print(me);
      // Handle received messages
      // print('Received message from $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.recipientId}'),
      ),
      body: Column(
        children: [
          // Your chat messages UI here

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
                  await _signalRService.sendMessage( _messageController.text);
                  print("hajde");
                 // _messageController.clear();
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
    _signalRService.disconnect();
    super.dispose();
  }
}
