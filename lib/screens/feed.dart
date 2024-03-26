import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/screens/nearby_posts_feed.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:friendly_mobile_app/widgets/post_card.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/post.dart';
import 'add_post_screen.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  bool hasMore = true;
  bool isLoading = false;
  final controller = ScrollController();
  List<Post> _posts = [];

Future<void> fetch() async {
    if (isLoading) return;

    const limit = 5;

    setState(() {
      isLoading = true;
    });

    String token =  await UserPreferences().getToken();

     final response = await http.get(
        Uri.parse('https://localhost:7169/post/friends?limit=$limit${_posts.isNotEmpty ? '&cursor=${_posts.last.id}' : ''}'),
         headers: {
          'Authorization': 'Bearer $token',
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
      IconButton(onPressed: (){
        showSearch(context: context, delegate: CustomSearchDelegate(),);
      },
       icon: const Icon(Icons.search)),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          );
        },
        child: Text('Add Post'),
      ),
      PopupMenuButton(
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: "logout",
            child:const Text("Logout"),
          ),
        ],
        onSelected: (value) {
          if (value == "logout") {
               _showLogoutConfirmationDialog(context);
          }
        },
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


void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                UserPreferences().removeUser();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }


class CustomSearchDelegate extends SearchDelegate {
  List<String> searchTerms = ["Apple", "Banana", "Pear", "Watermelons", "Oranges", "Kiwi", "Tomato"];
  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(onPressed: () { query = "";}, icon: const Icon(Icons.clear))];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(onPressed: () { close(context, null);}, icon: const Icon(Icons.arrow_back));
  }

   @override
  Widget buildResults(BuildContext context) {
    print("test");
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if(fruit.toLowerCase().contains(query.toLowerCase())) {
       // matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
      var result = matchQuery[index];

      return ListTile(
        title: Text(result),
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
     List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if(fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
      var result = matchQuery[index];

      return ListTile(
        title: Text(result),
      );
    });
  }
}