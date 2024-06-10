import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friendly_mobile_app/report_post_dialog.dart';
import 'package:friendly_mobile_app/screens/edit_post_screen.dart';
import 'package:friendly_mobile_app/screens/user_profile.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../domain/post.dart';
import '../domain/user.dart';
import '../providers/user_provider.dart';
import '../utility/app_url.dart';
import '../utility/shared_preference.dart';
import '../utility/time.dart';
import 'comment_modal.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final Function(int postId) onDelete;

  PostCard({
    required this.onDelete,
    required this.post
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = true;

  _test () async {
    String token =  await UserPreferences().getToken();

   final response = await http.delete(
        Uri.parse('${AppUrl.baseUrl}/Post/${widget.post.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if(response.statusCode == 200) {
        widget.onDelete(widget.post.id);
      } else {
        widget.onDelete(widget.post.id);
      }

       Fluttertoast.showToast(
          msg: 'Post deleted successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
  }
   void _showReportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ReportPostDialog(postId: widget.post.id,);
    },
  );
}
@override
  Widget build(BuildContext context) {
    Color likeIconColor = widget.post.isLikedByUser ? Colors.blue : Colors.grey;
    final User? user = Provider.of<UserProvider>(context).user;


    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0.0),
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
                  builder: (context) => UserProfilePage(user: widget.post.user ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if (widget.post.profileImage.isNotEmpty)
                    CircleAvatar(
                      radius: 20.0,
                      backgroundImage: NetworkImage(widget.post.profileImage),
                    ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: widget.post.username,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Adjust the color as needed
                              ),
                            ),
                            if (user?.id == widget.post.userId)
                              TextSpan(
                                text: " (you)",
                                style: TextStyle(
                                  fontSize: 12.0, // Adjust the font size as needed
                                  color: Colors.grey, // Adjust the color as needed
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.0),
                     Row(
  children: [
    Icon(
      Icons.public,
      color: Colors.grey,
      size: 16.0, // Adjust the size of the icon as needed
    ),
    SizedBox(width: 4), // Adjust the spacing between the icon and text as needed
    Text(
      calculateTimeAgo(widget.post.dateCreated),
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12.0,
      ),
    ),
  ],
),
                    ],
                  ),
                  Expanded(
                child: Align(
  alignment: Alignment.topRight,
  child: PopupMenuButton<String>(
    onSelected: (value) {
      if (value == 'edit') {
        // Handle edit post
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPostScreen(
              description: widget.post.description,
              postId: widget.post.id,
              imagePath: widget.post.postImage,
            ),
          ),
        );
      } else if (value == 'delete') {
        _test();
      } else if (value == 'report') {
        _showReportDialog(context);
      }
    },
    itemBuilder: (BuildContext context) {
      List<PopupMenuEntry<String>> menuItems = [];
      
      if (user?.id == widget.post.userId) {
        menuItems.addAll([
          PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
              title: Text('Edit'),
              trailing: Icon(Icons.edit, color: Colors.blue),
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              title: Text('Delete'),
              trailing: Icon(Icons.delete, color: Colors.red),
            ),
          ),
        ]);
      } else {
        menuItems.add(
          PopupMenuItem<String>(
            value: 'report',
            child: ListTile(
              title: Text('Report'),
              trailing: Icon(Icons.report, color: Colors.orange),
            ),
          ),
        );
      }

      return menuItems;
    },
    icon: Icon(Icons.more_vert),
  ),
),


              ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              widget.post.hobbyName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                widget.post.description,
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
            height: ( widget.post.postImage.isNotEmpty && widget.post.postImage != '')
                ? 400.0
                : 0.0,
            child: (widget.post.postImage.isNotEmpty)
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0.0),
                      image: DecorationImage(
                        image: NetworkImage(widget.post.postImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async{
                       String token =  await UserPreferences().getToken();

                      // Handle like post
                      final Map<String, dynamic> apiBodyData = {
                        "postId": widget.post.id };
                      var response = await post(
                      Uri.parse(AppUrl.likePost),
                      body: json.encode(apiBodyData),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ' + token.toString(), // Include the token in the headers
                      },
                    );

                    setState(() {
                      widget.post.isLikedByUser = !widget.post.isLikedByUser;

                      widget.post.likes +=
                          widget.post.isLikedByUser ? 1 : -1;
                      likeIconColor = widget.post.isLikedByUser
                          ? Colors.blue
                          : Colors.grey;
                    });
                  },
                  child: Icon(
                   FeatherIcons.thumbsUp,
                    color: likeIconColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  widget.post.likes.toString(),
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
                          postId: widget.post.id,
                          initialComments: widget.post.comments,
                          postLikes: widget.post.likes,
                          isLikedByUser: widget.post.isLikedByUser,
                        );
                      },
                    );
                  },
                  child: Icon(
                    FeatherIcons.messageSquare,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  widget.post.comments.toString(),
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


