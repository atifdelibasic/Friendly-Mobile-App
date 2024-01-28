import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/domain/like.dart';
import 'package:friendly_mobile_app/screens/userProfile.dart';
import 'package:http/http.dart' as http;

import '../domain/comment.dart';
import '../utility/time.dart';

class PostCard extends StatefulWidget {
  final String profileImage;
  final String username;
  final String description;
  final String postImage;
  int likes;
  final int id;
  final int comments;
  bool isLikedByUser;
  final String dateCreated;

  PostCard({
    required this.id,
    required this.profileImage,
    required this.username,
    required this.description,
    required this.postImage,
    required this.likes,
    required this.comments,
    required this.isLikedByUser,
    required this.dateCreated
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
     Color likeIconColor = widget.isLikedByUser ? Colors.blue : Colors.grey;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      // padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       GestureDetector(
      onTap: () {
        // Navigate to the user profile page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(userId: 1),
          ),
        );
      },
      child: Padding( 
        padding: const EdgeInsets.all(8.0),
  child: Row(
    children: [
      if (widget.profileImage.isNotEmpty)
        CircleAvatar(
          radius: 20.0,
          backgroundImage: NetworkImage(widget.profileImage),
        ),
      SizedBox(width: 8.0),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.username,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            calculateTimeAgo(widget.dateCreated),

            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    ],
  ),
),
       ),
          SizedBox(height: 16.0),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: 
            Padding(
              padding: EdgeInsets.all(8.0),
              child:
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 14.0,
                height: 1.5,
                color: Colors.black,
              ),
              maxLines: _isExpanded ? null : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ),
          SizedBox(height: 16.0),
        Container(
          height: (widget.postImage != null && widget.postImage.isNotEmpty) ? 400.0 : 0.0,
          child: (widget.postImage != null && widget.postImage.isNotEmpty)
            ? Container(
                width: double.infinity, // Set the width to be full
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.0),
                  image: DecorationImage(
                    image: NetworkImage(widget.postImage),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : null,
        ),
          SizedBox(height: 16.0),
          Padding(
            padding: EdgeInsets.fromLTRB(10,0,0,10),
            child:
          Row(
            children: [
              GestureDetector(
                onTap: () {
                   setState(() {
                     try {
                      final response =  http.post(
                        Uri.parse('https://localhost:7169/Like'),
                        headers: {
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImF0aWYuZGVsaWJhc2ljQGdtYWlsLmNvbSIsInVzZXJpZCI6IjEiLCJmaXJzdG5hbWUiOiJBdGlmIiwibGFzdG5hbWUiOiJEZWxpYmFzaWMiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiZXhwIjoxNzA2NTMzMTc5LCJpc3MiOiJodHRwOi8vZnJpZW5kbHkuYXBwIiwiYXVkIjoiaHR0cDovL2ZyZWluZGx5LmFwcCJ9._PtUy1JHQGO_A7xpEc1NXeEBu5V7IrfyeahZB6wV5tk', // Include the token in the headers
                        },
                        body: jsonEncode(<String, String>{
                          'postId': widget.id.toString(),
                        }),
                      );

                    } catch (e) {
                      // Handle API call error
                      print('API call failed: $e');
                    }
                 widget.isLikedByUser = !widget.isLikedByUser;
                 widget.likes +=  widget.isLikedByUser ? 1 : -1;
               likeIconColor = widget.isLikedByUser ? Colors.blue : Colors.grey;
              });
                },
                child: Icon(
                  Icons.thumb_up_alt_outlined,
                  color:  likeIconColor = widget.isLikedByUser ? Colors.blue : Colors.grey,
                ),
              ),
              SizedBox(width: 8.0),
              Text(
                widget.likes.toString(),
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 16.0),
              GestureDetector(
                onTap: () {
                   showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return CommentModal(
                    postId: widget.id,
                    initialComments: widget.comments,
                    postLikes: widget.likes,
                    isLikedByUser: widget.isLikedByUser,

                  );
                },
              );
                },
                child: Icon(
                  Icons.mode_comment_outlined,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 8.0),
              Text(
                widget.comments.toString(),
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }
}

class CommentModal extends StatefulWidget {
  final int postId;
  final int initialComments;
  final int postLikes;
  final bool isLikedByUser;

  CommentModal({ required this.postId, required this.initialComments,  required this.postLikes, required this.isLikedByUser});

  @override
  _CommentModalState createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  List<Comment> comments = [];
  bool isLoading = false;
  bool hasMore = true;
  final controller = ScrollController();
   TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments();

    controller.addListener(() {
      print("Scroll Position: ${controller.offset}");
      if (controller.position.maxScrollExtent - controller.offset <= 100) {
        fetchComments();
      }
    });
  }

  Future<void> fetchComments() async {
    print("fetch");
    if (isLoading || !hasMore) return;
    const limit = 10;

    setState(() {
      isLoading = true;
    });

    // Simulating a delay to show loading indicator
     final response = await http.get(
        Uri.parse('https://localhost:7169/Comment/cursor?postId=${widget.postId}&limit=$limit${comments.isNotEmpty ? '&cursor=${comments.last.id}' : ''}'),
         headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImF0aWYuZGVsaWJhc2ljQGdtYWlsLmNvbSIsInVzZXJpZCI6IjEiLCJmaXJzdG5hbWUiOiJBdGlmIiwibGFzdG5hbWUiOiJEZWxpYmFzaWMiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiZXhwIjoxNzA2NTMzMTc5LCJpc3MiOiJodHRwOi8vZnJpZW5kbHkuYXBwIiwiYXVkIjoiaHR0cDovL2ZyZWluZGx5LmFwcCJ9._PtUy1JHQGO_A7xpEc1NXeEBu5V7IrfyeahZB6wV5tk', // Include the token in the headers
        },
      );

       if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

       final List<Comment> items = responseData.map((data) {
          return Comment.fromJson(data);
        }).toList();

            setState(() {
          isLoading = false;
          if (items.length < limit) {
            print("false");
            hasMore = false;
          } else {
            print("ima jos");
            hasMore = true;
          }
          print("dodaj hin");
          comments.addAll(items);
        });
       } else {
        throw Exception('Failed to load data');
      }
  }

  Future<void> _submitComment(int postId, String text) async {
    print("dosao u metodu");
    print(postId);
    try {
     final response = await http.post(
        Uri.parse('https://localhost:7169/Comment/'),
         headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImF0aWYuZGVsaWJhc2ljQGdtYWlsLmNvbSIsInVzZXJpZCI6IjEiLCJmaXJzdG5hbWUiOiJBdGlmIiwibGFzdG5hbWUiOiJEZWxpYmFzaWMiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiZXhwIjoxNzA2Nzg4ODQ5LCJpc3MiOiJodHRwOi8vZnJpZW5kbHkuYXBwIiwiYXVkIjoiaHR0cDovL2ZyZWluZGx5LmFwcCJ9.SWVVOW_fomf8Fp4OrjFy3V6dHH0FsGh4_k9VIJfKU6g', // Include the token in the headers
        },
        body: jsonEncode({
          'postId': postId,
          'text': text
        }),
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        comments = [];
        fetchComments();
        print('Comment submitted successfully');
      } else {
        print('Failed to submit comment. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error submitting comment: $error');
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(20)),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return LikesModal(postId: widget.postId);
                },
              );
            },
            child: Row(
              children: [
                Padding(padding: EdgeInsets.all(9)),
                Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Icon(
                    size: 10,
                    Icons.thumb_up,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  widget.postLikes == 1 && widget.isLikedByUser
                      ? 'You like this'
                      : widget.isLikedByUser
                          ? 'You and ${widget.postLikes - 1} people like this'
                          : '${widget.postLikes} people like this',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
  child: ListView.builder(
    controller: controller,
    itemCount: comments.length + (hasMore ? 1 : 0),
    itemBuilder: (context, index) {
      if (index < comments.length) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage("https://localhost:7169/images/" + comments[index].profileImageUrl),
          ),
          title: Text(comments[index].text, style: TextStyle(fontSize: 14)),
          subtitle: Text(
            'by ${comments[index].fullName} • ${calculateTimeAgo(comments[index].dateCreated)}',
          ),
        );
      } else {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : Text('No more comments to load'),
          ),
        );
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
        controller: _commentController,
        decoration: InputDecoration(hintText: 'Add a comment...'),
        onChanged: (text) {
          // Handle text changes
        },
        onSubmitted: (text) {
          // You can choose to submit the comment here as well if needed
         // _submitComment(widget.postId, text);
         print("ovdje sam on sbmitted");
          _commentController.clear();
        },
      ),
    ),
    SizedBox(width: 8.0),
    ElevatedButton(
      onPressed: () {
        final text = _commentController.text;
        if (text.isNotEmpty) {
          print("ovdje sam");
          print(text);
          _submitComment(widget.postId, text);
          _commentController.clear();
        }
      },
      child: Text('Post'),
    ),
  ],
),
          ),
        ],
      ),
    );
  }
}

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

     final response = await http.get(
        Uri.parse('https://localhost:7169/like?postId=${widget.postId}&limit=$limit${likes.isNotEmpty ? '&cursor=${likes.last.id}' : ''}'),
         headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImF0aWYuZGVsaWJhc2ljQGdtYWlsLmNvbSIsInVzZXJpZCI6IjEiLCJmaXJzdG5hbWUiOiJBdGlmIiwibGFzdG5hbWUiOiJEZWxpYmFzaWMiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiZXhwIjoxNzA2NTMzMTc5LCJpc3MiOiJodHRwOi8vZnJpZW5kbHkuYXBwIiwiYXVkIjoiaHR0cDovL2ZyZWluZGx5LmFwcCJ9._PtUy1JHQGO_A7xpEc1NXeEBu5V7IrfyeahZB6wV5tk', // Include the token in the headers
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
                title: Text(user.profileImageUrl),
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