import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:provider/provider.dart';
import '../domain/message.dart';
import '../domain/user.dart';
import '../providers/user_provider.dart';
import '../services/signalr_service.dart';
import '../utility/app_url.dart';
import 'package:http/http.dart' as http;

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
  late List<Map<String, dynamic>> _messages = [
   
  ];

  @override
  void initState() {
    super.initState();
    initializeChat();

  }
  void initializeChat() async {
  await fetchMessages(); 
  initializeToken(); 
}

  Future<void> fetchMessages() async {
    String token = await UserPreferences().getToken();
    var user = await UserPreferences().getUser();
    String url = "${AppUrl.baseUrl}/chat?recipientId=${widget.recipientId}&limit=0";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Message> messages = data.map((json) => Message.fromJson(json)).toList();

        List<Map<String, dynamic>> msgs =  messages.map((msg) {
      return {
        'message': msg.content,
        'isMe': msg.senderId == user.id
      };
    }).toList();

       setState(() {
    _messages = msgs;
  });
    } else {
      print('Error fetching messages: ${response.statusCode}');
    }
  }

  void initializeToken() async {
    var token = await UserPreferences().getToken();
    await _signalRService.connect('${AppUrl.baseUrl}/example?recipient_id=${widget.recipientId}', token);

    
  _signalRService.onReceiveMessage((message, isMe) {
    var updatedMessages = List<Map<String, dynamic>>.from(_messages);
    updatedMessages.insert(0,{'message': message, 'isMe': isMe});

    setState(() {
      _messages = updatedMessages;
    });
  });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.recipientProfileImage),
              radius: 16,
            ),
            SizedBox(width: 8),
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
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!message['isMe'])
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(widget.recipientProfileImage),
                                radius: 20,
                              ),
                            ),
                          Expanded(
                            child: Align(
                              alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0, 4, 10, 4),
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
    _signalRService.disconnect();
    super.dispose();
  }
}
