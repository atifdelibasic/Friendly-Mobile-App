import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:friendly_mobile_app/widgets/post_card.dart';
import 'package:geolocator/geolocator.dart';
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
    double? latitude;
  double? longitude;
  bool isLocationLoading = false;


  Future<void> _getLocation() async {
  setState(() {
    isLocationLoading = true;
  });

  _showLoadingIndicator(context, 'Fetching Location...');

  LocationPermission permission;
  permission = await Geolocator.requestPermission();
  
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      isLocationLoading = false;
    });

    _hideLoadingIndicator(context);

  } catch (e) {
    setState(() {
      isLocationLoading = false;
    });
    _hideLoadingIndicator(context);
    print('Error getting location: $e');
  }
}

Future<void> fetch() async {
  
  await _getLocation();
    if (isLoading) return;

    const limit = 5;

    setState(() {
      isLoading = true;
    });

    String token = await UserPreferences().getToken();

     final response = await http.get(
        Uri.parse('https://localhost:7169/post/nearby?longitude=${longitude}&latitude=${latitude}&limit=$limit${_posts.isNotEmpty ? '&cursor=${_posts.last.id}' : ''}'),
         headers: {
          'Authorization': 'Bearer $token', 
        },
      );
      isLoading = false;
      print("status code");
      print(response.statusCode);

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
        print(response.statusCode);
        throw Exception('Failed to load data');
      }
}

void _showLoadingIndicator(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text(message),
          ],
        ),
      );
    },
  );
}

void _hideLoadingIndicator(BuildContext context) {
  Navigator.of(context).pop();
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
      body:_posts.isEmpty? Container()
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
