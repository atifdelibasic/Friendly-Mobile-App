import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:friendly_mobile_app/widgets/post_card.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/post.dart';
import 'add_post_screen.dart';
import 'feed.dart';

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
          'Authorization': 'Bearer ' + token.toString(), // Include the token in the headers
        },
      );
      isLoading = false;

       if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        final List<Post> items = responseData.map((responseData) {
            return Post.fromJson(responseData);
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
                post: _posts[index],
                onDelete: (postId) {
                   setState(() {
                    _posts.removeWhere((post) => post.id == postId);
                  });
                },
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
