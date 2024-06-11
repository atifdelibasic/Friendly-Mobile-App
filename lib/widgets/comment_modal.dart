import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../domain/comment.dart';
import '../utility/app_url.dart';
import '../utility/shared_preference.dart';
import '../utility/time.dart';
import 'like_modal.dart';

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
      if (controller.position.maxScrollExtent - controller.offset <= 100) {
        fetchComments();
      }
    });
  }

  Future<void> fetchComments() async {
    if (isLoading || !hasMore) { 
      return;
    }
    const limit = 20;

    setState(() {
      isLoading = true;
    });

    String token =  await UserPreferences().getToken();

     final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/Comment/cursor?postId=${widget.postId}&limit=$limit${comments.isNotEmpty ? '&cursor=${comments.last.id}' : ''}'),
         headers: {
          'Authorization': 'Bearer $token', 
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
            hasMore = false;
          } else {
            hasMore = true;
          }
          comments.addAll(items);
        });
       } else {
        throw Exception('Failed to load data');
      }
  }

  Future<void> _submitComment(int postId, String text) async {
    try {

    String token =  await UserPreferences().getToken();
     final response = await http.post(
        Uri.parse('${AppUrl.baseUrl}/Comment/'),
         headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode({
          'postId': postId,
          'text': text
        }),
      );

      if (response.statusCode == 200) {
          comments = [];
          isLoading = false;
          hasMore = true;

       await fetchComments();
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
            backgroundImage: NetworkImage( comments[index].profileImageUrl),
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
          _commentController.clear();
        },
      ),
    ),
    SizedBox(width: 8.0),
    ElevatedButton(
      onPressed: () {
        final text = _commentController.text;
        if (text.isNotEmpty) {
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
