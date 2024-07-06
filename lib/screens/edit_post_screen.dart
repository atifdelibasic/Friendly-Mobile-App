import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../utility/app_url.dart';
import '../utility/shared_preference.dart';
import 'feed.dart';

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

  @override
  void initState() {
    super.initState();
    descriptionController.text = widget.description;
  }

  Future<void> _updatePost() async {
    try {
      String token = await UserPreferences().getToken();

      final response = await http.put(
        Uri.parse('${AppUrl.baseUrl}/Post/${widget.postId}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ' + token,
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
        print('Failed to update post: ${response.body}');
      }
    } catch (e) {
      print('Error updating post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = descriptionController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Edit Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: descriptionController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter your description',
                errorText: descriptionController.text.isEmpty ? 'Description is required' : null,
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16.0),
            if (widget.imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isButtonEnabled ? _updatePost : null,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Update Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
