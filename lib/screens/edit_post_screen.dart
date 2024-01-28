import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/screens/feed.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class EditPostScreen extends StatefulWidget {
  final String description;
  final int postId;
  final String imagePath;

  EditPostScreen({required this.description, required this.postId, required this.imagePath});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();

}

class _EditPostScreenState extends State<EditPostScreen> {
  TextEditingController descriptionController = TextEditingController();
  String imageUrl = '';

   @override
  void initState() {
    super.initState();
  
      descriptionController.text = widget.description;
    
  }

  Future<void> _createPost() async {
    try {
      final response = await http.put(
        Uri.parse('https://localhost:7169/Post/' + widget.postId.toString()),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImF0aWYuZGVsaWJhc2ljQGdtYWlsLmNvbSIsInVzZXJpZCI6IjEiLCJmaXJzdG5hbWUiOiJBdGlmIiwibGFzdG5hbWUiOiJEZWxpYmFzaWMiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiZXhwIjoxNzA2ODk0ODI3LCJpc3MiOiJodHRwOi8vZnJpZW5kbHkuYXBwIiwiYXVkIjoiaHR0cDovL2ZyZWluZGx5LmFwcCJ9.CbtclDI3dsXlmNFC1XCKmXL2hZRE_KYXvAqoqC-F26k', // Replace with your actual access token
        },
        body: jsonEncode({
          'description': descriptionController.text,
        }),
      );

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg: 'Post updated successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Feed()),
        );

      } else {
        print('Failed to create post: ${response.body}');
      }
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
  bool isButtonEnabled = descriptionController.text.isNotEmpty;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text('Update Post'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: descriptionController,
            onChanged: (value) {
              setState(() {
                // Update the state when the description changes
              });
            },
            decoration: InputDecoration(
              labelText: 'Description',
              errorText: descriptionController.text.isEmpty
                  ? 'Description is required'
                  : null,
            ),
          ),
          SizedBox(height: 16.0),
          // Display image if imagePath is not empty
          if (widget.imagePath != null && widget.imagePath.isNotEmpty)
            Image.network(
              widget.imagePath,
              height: 200, // Set the desired height
              fit: BoxFit.cover,
            ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: isButtonEnabled
                ? () {
                    _createPost();
                  }
                : null,
            child: Text('Update post'),
          ),
        ],
      ),
    ),
  );
}

}