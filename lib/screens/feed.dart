import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/rate_app_dialog.dart';
import 'package:friendly_mobile_app/screens/notifications_screen.dart';
import 'package:friendly_mobile_app/screens/user_profile.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:friendly_mobile_app/widgets/post_card.dart';
import 'package:friendly_mobile_app/widgets/bottom_navigation_bar.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import '../domain/post.dart';
import '../domain/user.dart';
import '../feedback_dialog.dart';
import '../providers/user_provider.dart';
import '../utility/app_url.dart';
import 'add_post_screen.dart';
import 'placeholders.dart';

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

  Future<void> fetch({bool initialLoad = false}) async {
    if (isLoading) return;

    const limit = 5;

    setState(() {
      isLoading = true;
    });

    if (initialLoad) {
      // Add a delay for the initial load
      await Future.delayed(Duration(seconds: 1));
    }

    String token = await UserPreferences().getToken();

    final response = await http.get(
      Uri.parse(
          '${AppUrl.baseUrl}/post/friends?limit=$limit${_posts.isNotEmpty ? '&cursor=${_posts.last.id}' : ''}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    setState(() {
      isLoading = false;
    });

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
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetch(initialLoad: true);

    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
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

    fetch(initialLoad: true);
  }

  void _showFeedbackDialog(BuildContext context) {
    print("modal");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FeedbackDialog();
      },
    );
  }

  void _showRateAppDialog(BuildContext context) {
    print("modal");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RateAppDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var user1 = Provider.of<UserProvider>(context, listen: true).user;
    print( user1!.profileImage.toString());

    return Scaffold(
      appBar: AppBar(
        // title: Text('Friendly'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        leadingWidth: 45,
        leading: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserProfilePage(user: user1)),
            );
          },
          child: SizedBox(
            height: 100,
            width: 10,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0), // Add padding to the left
              child: CircleAvatar(
                backgroundImage: NetworkImage(user1.profileImage),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon( Icons.notifications), onPressed: () {
             Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsScreen(),
                            ),
                          );
          },),
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
              icon: const Icon(Icons.search)),
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout,
                        color: Colors.grey), 
                    SizedBox(width: 8), 
                    Text("Logout"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "feedback",
                child: Row(
                  children: [
                    Icon(Icons.feedback,
                        color: Colors.grey), // Add icon for feedback
                    SizedBox(width: 8), // Add spacing between icon and text
                    Text("Feedback"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "rate",
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.grey), // Add icon for rating
                    SizedBox(width: 8), // Add spacing between icon and text
                    Text("Rate app"),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == "logout") {
                _showLogoutConfirmationDialog(context);
              } else if (value == "feedback") {
                _showFeedbackDialog(context);
              } else if (value == "rate") {
                _showRateAppDialog(context);
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        index: 0,
        context: context,
      ),
      body: _posts.isEmpty && isLoading
          ? Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              enabled: true,
              child: const SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(height: 16.0),
                      ContentPlaceholder(
                        lineType: ContentLineType.twoLines,
                      ),
                      SizedBox(height: 16.0),
                      ContentPlaceholder(
                        lineType: ContentLineType.twoLines,
                      ),
                      ContentPlaceholder(
                        lineType: ContentLineType.twoLines,
                      ),
                    ]),
              ))
          : _posts.isEmpty
              ? Center(child: Text("No posts to show."))
              : RefreshIndicator(
                  onRefresh: _refreshFeed,
                  child: ListView.builder(
                      itemCount: _posts.length + 1,
                      controller: controller,
                      itemBuilder: (context, index) {
                        if (index < _posts.length) {
                          return PostCard(
                            post: _posts[index],
                            onDelete: (postId) {
                              setState(() {
                                _posts.removeWhere((post) => post.id == postId);
                              });
                            },
                          );
                        } else {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                                child: hasMore
                                    ? CircularProgressIndicator()
                                    : Text('No more data to load')),
                          );
                        }
                      }),
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
            onPressed: () async{
              UserPreferences().removeUser();
              await Future.delayed(Duration(seconds: 1));
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text("Logout"),
          ),
        ],
      );
    },
  );
}

class CustomSearchDelegate extends SearchDelegate<Future<Widget>?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  Future<List<User>> serachdb() async {
    String token = await UserPreferences().getToken();

    final response = await http.get(
      Uri.parse(
          '${AppUrl.baseUrl}/User/cursor?limit=99&text=${query.toLowerCase()}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final List<dynamic> responseData = json.decode(response.body);

    final List<User> items = responseData.map((responseData) {
      return User.fromJson(responseData);
    }).toList();

    return items;
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: serachdb(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<User>? users = snapshot.data;
          return ListView.builder(
            itemCount: users!.length,
            itemBuilder: (context, index) {
              User user = users[index];
              return GestureDetector(
                onTap: () {
                  print("alo");
                  // Navigate to the detail screen when the ListTile is tapped
                },
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // You can add any additional action here if needed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfilePage(user: user)),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.profileImage),
                      ),
                      title: Text(
                        "${user.firstName} ${user.lastName}",
                        style: TextStyle(
                            fontSize: 16.0), // Adjust the font size as needed
                      ),
                      subtitle: Text(
                        user.email,
                        style: TextStyle(
                            fontSize: 14.0), // Adjust the font size as needed
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text("");
  }
}
