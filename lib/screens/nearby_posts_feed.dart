import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:friendly_mobile_app/screens/test.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'add_post_screen.dart';
import 'feed.dart';

class Post {
  final int id;
  final String profileImage;
  final String username;
  final String postImage;
  final String description;
  final int likes;
  final int comments;
  final bool isLikedByUser;
  final String dateCreated;
  final String hobbyName;

  Post({
    required this.id,
    required this.profileImage,
    required this.username,
    required this.postImage,
    required this.description,
    required this.likes,
    required this.comments,
    required this.isLikedByUser,
    required this.dateCreated,
    required this.hobbyName
  });
}

class NearbyPostsFeed extends StatefulWidget {
  const NearbyPostsFeed({Key? key}) : super(key: key);
  @override
  _NearbyPostsFeed createState() => _NearbyPostsFeed();
}

class _NearbyPostsFeed extends State<NearbyPostsFeed> {

  bool hasMore = true;
  bool test = false;
  bool isLoading = false;
  final controller = ScrollController();
  List<Post> _posts = [];

Future<void> fetch() async {
    if (isLoading) return;

    const limit = 5;

    setState(() {
      isLoading = true;
    });

    Future<String> token = UserPreferences().getToken();

     final response = await http.get(
        Uri.parse('https://localhost:7169/post/friends?limit=$limit${_posts.isNotEmpty ? '&cursor=${_posts.last.id}' : ''}'),
        // Add any necessary headers or parameters here
         headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImF0aWYuZGVsaWJhc2ljQGdtYWlsLmNvbSIsInVzZXJpZCI6IjEiLCJmaXJzdG5hbWUiOiJBdGlmIiwibGFzdG5hbWUiOiJEZWxpYmFzaWMiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJVc2VyIiwiZXhwIjoxNzA2ODk0ODI3LCJpc3MiOiJodHRwOi8vZnJpZW5kbHkuYXBwIiwiYXVkIjoiaHR0cDovL2ZyZWluZGx5LmFwcCJ9.CbtclDI3dsXlmNFC1XCKmXL2hZRE_KYXvAqoqC-F26k', // Include the token in the headers
        },
      );
      isLoading = false;

       if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        final List<Post> items = responseData.map((data) {
          final user = data['user'];
          final firstName = user['firstName'] as String;
          final lastName = user['lastName'] as String;
          final fullName = '$firstName $lastName';
          final profileImageUrl = 'https://localhost:7169/images/' + user['profileImageUrl'] as String? ?? 'https://ui-avatars.com/api/?rounded=true&name=$firstName+$lastName';
          print(profileImageUrl);
          return Post(
            id: data['id'] ?? '', 
            profileImage:  profileImageUrl, // Adjust this based on your API response
            username: '${data['user']['firstName']} ${data['user']['lastName']}',
            postImage:  data['imagePath'] ?? '', // Adjust this based on your API response
            description: data['description'] ?? '',
            likes: data['likeCount'] ?? 0,
            comments: data['commentCount'] ?? 0,
            isLikedByUser: data['isLikedByUser'] ?? false,
            dateCreated: data['dateCreated'],
            hobbyName: data['hobby']['title']
          );
        }).toList();

            setState(() {
          isLoading = false;
          if (items.length < limit) {
            hasMore = false;
          } else {
            hasMore = true;
          }

          _posts.addAll(items);

        });
       } else {
        throw Exception('Failed to load data');
      }
}
  @override
  void initState() {
    super.initState();
    fetch();

    controller.addListener(() {
      print("scroll");
      if(controller.position.maxScrollExtent == controller.offset) {
        fetch();
       }
    });
  }

  Future<void> _refreshFeed() async {
   
    setState(() {
      isLoading = false;
      hasMore = true;
      _posts.clear();
    });

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Text('Friendly'),
         automaticallyImplyLeading: false,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPostScreen()),
              );
            },
            child: Text('Add Post'),
          ),
        ],
      ),
    bottomNavigationBar: BottomAppBar(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                   Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Feed()),
                );
              },
            ),
            Text('Home'),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.location_on),
              onPressed: () {
                   Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NearbyPostsFeed()),
                );
              },
            ),
            Text('Nearby'),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () {
                // Add your friend requests icon onPressed logic here
              },
            ),
            Text('Requests'),
          ],
        ),
      ],
    ),
  ),
      body:_posts.isEmpty? const Center(child:CircularProgressIndicator())
      : RefreshIndicator(
        onRefresh: _refreshFeed,
        child: ListView.builder(
          itemCount: _posts.length + 1,
          controller: controller,
          itemBuilder: (context, index) {
            if(index < _posts.length ) {
              return PostCard(
                id: _posts[index].id,
                comments: _posts[index].comments,
                likes: _posts[index].likes,
                profileImage: _posts[index].profileImage,
                postImage: _posts[index].postImage.isNotEmpty
                ? "https://localhost:7169/images/" + _posts[index].postImage
                : "",
                username: _posts[index].username,
                description: _posts[index].description,
                isLikedByUser: _posts[index].isLikedByUser,
                dateCreated: _posts[index].dateCreated,
                hobbyName: _posts[index].hobbyName,
              );} else {
                return  Padding(
                  padding: EdgeInsets.symmetric(vertical:32),
                  child: Center(child: hasMore?  CircularProgressIndicator() : Text('No more data to load')),
                );
              }
            }
        ),
      ),
    );
  }
}
