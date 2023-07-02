import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/providers/auth_provider.dart';
import 'package:friendly_mobile_app/providers/user_provider.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:friendly_mobile_app/screens/test.dart';
import 'package:friendly_mobile_app/domain/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Post {
  final String profileImage;
  final String username;
  final String postImage;
  final String description;
  final int likes;
  final int comments;

  Post({
    required this.profileImage,
    required this.username,
    required this.postImage,
    required this.description,
    required this.likes,
    required this.comments,
  });
}

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  List<Post> _posts = [
    Post(
      profileImage:
          "https://www.shutterstock.com/image-photo/head-shot-portrait-close-smiling-260nw-1714666150.jpg",
      postImage:
          "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_960_720.jpg",
      description: "Testiranje jarane",
      username: "Lorem Ipsum",
      likes: 102,
      comments: 11,
    ),
    Post(
      profileImage:
          "https://www.shutterstock.com/image-photo/head-shot-portrait-close-smiling-260nw-1714666150.jpg",
      postImage:
          "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_960_720.jpg",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed auctor dolor et risus suscipit, id interdum dolor blandit. Ut volutpat hendrerit sem, a bibendum tellus venenatis et. Pellentesque id est id purus sollicitudin sagittis eget in lectus. Mauris et nulla nibh. Proin eu sapien eget dui maximus molestie.",
      username: "John Doe",
      likes: 23,
      comments: 7,
    ),
    Post(
      profileImage:
          "https://www.shutterstock.com/image-photo/head-shot-portrait-close-smiling-260nw-1714666150.jpg",
      postImage:
          "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_960_720.jpg",
      description:
          "Ut vel tristique augue, non vulputate augue. Sed porttitor a ante ut fringilla. Aliquam euismod a enim ut molestie. Proin maximus ex quam, sit amet luctus mauris rhoncus at. Duis bibendum, augue eu eleifend lacinia, mi sapien aliquet dolor, id bibendum nulla odio vitae ante. ",
      username: "Jane Doe",
      likes: 57,
      comments: 12,
    ),
  ];

  Future<void> _refreshFeed() async {
    // You can add your logic for fetching new data here
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _posts.add(Post(
        profileImage:
            "https://www.shutterstock.com/image-photo/head-shot-portrait-close-smiling-260nw-1714666150.jpg",
        postImage:
            "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_960_720.jpg",
        description: "This is a new post.",
        username: "John Smith",
        likes: 0,
        comments: 0,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Feed'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            return PostCard(
              comments: _posts[index].comments,
              likes: _posts[index].likes,
              profileImage: _posts[index].profileImage,
              postImage: _posts[index].postImage,
              username: _posts[index].username,
              description: _posts[index].description,
            );
          },
        ),
      ),
    );
  }
}
