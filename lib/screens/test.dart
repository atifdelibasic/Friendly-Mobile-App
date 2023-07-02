import 'package:flutter/material.dart';
class PostCard extends StatefulWidget {
  final String profileImage;
  final String username;
  final String description;
  final String postImage;
  final int likes;
  final int comments;

  PostCard({
    required this.profileImage,
    required this.username,
    required this.description,
    required this.postImage,
    required this.likes,
    required this.comments,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
          Row(
            children: [
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
                    'Posted 2 hours ago',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.0),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
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
          SizedBox(height: 16.0),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0.0),
              image: DecorationImage(
                image: NetworkImage(widget.postImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.thumb_up_alt_outlined,
                  color: Colors.grey,
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
                onTap: () {},
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
        ],
      ),
    );
  }
}
