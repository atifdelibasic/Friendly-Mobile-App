import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../domain/like.dart';
import '../utility/shared_preference.dart';

class LikesModal extends StatefulWidget {
  final int postId;

  LikesModal({ required this.postId});

  @override
  _LikesModalState createState() => _LikesModalState();
}

class _LikesModalState extends State<LikesModal> {
  List<Like> likes = []; 
  bool isLoading = false;
  bool hasMore = true;
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchLikes();
    controller.addListener(() {
      print("Scroll Position: ${controller.offset}");

      if (controller.position.maxScrollExtent == controller.offset) {
        fetchLikes();
      }
    });
  }

  Future<void> fetchLikes() async {
    if (isLoading || !hasMore) return;
    const limit = 20;

    setState(() {
      isLoading = true;
    });

    String token =  await UserPreferences().getToken();

     final response = await http.get(
        Uri.parse('https://localhost:7169/like?postId=${widget.postId}&limit=$limit${likes.isNotEmpty ? '&cursor=${likes.last.id}' : ''}'),
         headers: {
          'Authorization': 'Bearer ' + token, // Include the token in the headers
        },
      );

       if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

       final List<Like> items = responseData.map((data) {
          return Like.fromJson(data);
        }).toList();

            setState(() {
          isLoading = false;
          if (items.length < limit) {
            hasMore = false;
          } else {
            hasMore = true;
          }

          likes.addAll(items);
        });
       } else {
        throw Exception('Failed to load data');
      }
  }


@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Padding(padding: EdgeInsets.all(15)),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back icon to navigate back to the CommentModal
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Close the LikesModal
              },
            ),
            Text(
              'People who liked this post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            // Placeholder for the space on the right side
            SizedBox(width: 40.0),
          ],
        ),
      ),
      // You can fetch and display the list of people who liked the post here
      Expanded(
        child: ListView.builder(
          controller: controller,
          itemCount: likes.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < likes.length) {
              var user = likes[index];
              return ListTile(
                leading: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Circular background with profile image
                    Container(
                      height: 45.0,
                      width: 45.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue, // Change color as needed
                        border: Border.all(
                          color: Colors.white, // Set the border color
                          width: 2.0, // Set the border width
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                         user.profileImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Thumbs-up icon in white color
                   Container(
                      margin: EdgeInsets.only(bottom: 0.0, right: 0),
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue, 
                         border: Border.all(
                          color: Colors.white,
                          width: 2.0, 
                        ),
                      ),
                      child: Icon(
                        Icons.thumb_up,
                        color: Colors.white,
                        size: 10.0,
                      ),
                    ),
                  ],
                ),
                title: Text(user.fullName),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : null,
                ),
              );
            }
          },
        ),
      ),
    ],
  );
}
}