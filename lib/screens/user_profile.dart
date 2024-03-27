import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/screens/chat.dart';
import 'package:friendly_mobile_app/utility/app_url.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:friendly_mobile_app/widgets/post_card.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../domain/post.dart';
import '../domain/user.dart';
import '../providers/user_provider.dart';

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({Key? key, required this.user}) : super(key: key);
  @override
  __UserProfilePageState createState() => __UserProfilePageState();
}

class __UserProfilePageState extends State<UserProfilePage> {

  bool hasMore = true;
  bool test = false;
  bool isLoading = false;
  final controller = ScrollController();
  List<Post> _posts = [];
  late int friendRequestStatus = 0;

  void fetchFriendRequestStatus() async {
    try {
      String token = await UserPreferences().getToken();
      print("user id");
      print(widget.user.id);
      print(token);
      final response = await http.get(
        Uri.parse("https://localhost:7169/Profiles/${widget.user.id}/friendship-status"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
 print("status");
      print(response.statusCode);
      Map<String, dynamic> responseData = json.decode(response.body);
     
    
      if (response.statusCode == 200) {
        // Parse the response and extract friend request status
        print("status je 200");
        setState(() {
      int status = responseData['status'];
  print("status");
      print(status);
         friendRequestStatus = status;
        });
      } else {
        throw Exception('Failed to fetch friend request status');
      }
      print("state");
      print(friendRequestStatus);
    } catch (e) {
      print('Error fetching friend request status: $e');
    }
  }

Future<void> fetch() async {
    if (isLoading) return;

    const limit = 5;

    setState(() {
      isLoading = true;
    });

    String token =  await UserPreferences().getToken();
    final uri = 'https://localhost:7169/Post/user?UserId=${widget.user.id}&limit=$limit${_posts.isNotEmpty ? '&cursor=${_posts.last.id}' : ''}';
     final response = await http.get(
        Uri.parse(uri),
         headers: {
          'Authorization': 'Bearer $token', 
        },
      );
      isLoading = false;

       if (response.statusCode == 200) {
        print("200");
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
    print("hello");
    super.initState();
    fetch();
    //fetchFriendRequestStatus();

    controller.addListener(() {
      if(controller.position.maxScrollExtent == controller.offset) {
        fetch();
       }
    });

    print("setano sve");
  }

  Future<void> _refreshFeed() async {
   
    setState(() {
      isLoading = false;
      hasMore = true;
      _posts.clear();
    });

    fetch();
    //fetchFriendRequestStatus();
  }

 @override
Widget build(BuildContext context) {

    User? user = Provider.of<UserProvider>(context).user;

  return Scaffold(
    appBar: AppBar(
      title: Text('User Profile'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
           // _showLogoutConfirmationDialog(context);
          },
        ),
      ],
    ),
    body
        : RefreshIndicator(
            onRefresh: _refreshFeed,
            child: ListView.builder(
              itemCount: _posts.length + 2,
              controller: controller,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Display user profile information
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                             widget.user.profileImage,
                            ),
                            radius: 60,
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            widget.user.firstName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                         buildFriendRequestButton(friendRequestStatus, widget.user.id, user?.id  ?? 0),
                         ElevatedButton(
                          onPressed: () {
                            // Navigate to the desired screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChatScreen(recipientId: widget.user.id, recipientProfileImage: widget.user.profileImage, fullName: widget.user.fullName,)),
                            );
                          },
                          child: Text('Start Chat'),
                        ),
                        Divider(), 
                      ],
                    ),
                  );
                } else if ((index <= _posts.length)) {
                  // Display posts
                  return PostCard(
                    post: _posts[index-1],
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
                          : Text('No more data to load'),
                    ),
                  );
                }
              },
            ),
          ),
  );
}
}
 // Function to build friend request button based on friendRequestStatus
 Widget buildFriendRequestButton(int friendRequestStatus, int id, int userId) {
  print("usao u  build");
  print(friendRequestStatus);

  if (friendRequestStatus == 0) {
    return ElevatedButton(
      onPressed: () {
        // Perform action to send friend request
        sendFriendRequest();
      },
      child: Text('Send Friend Request'),
    );
  } else if (friendRequestStatus == 1 && id == userId) {
    return ElevatedButton(
      onPressed: () {
        // Perform action to cancel friend request
        cancelFriendRequest();
      },
      child: Text('Cancel Friend Request'),
    );
  } else if (friendRequestStatus == 1) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            // Perform action to accept friend request
            acceptFriendRequest();
          },
          child: Text('Accept'),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            // Perform action to decline friend request
            declineFriendRequest();
          },
          child: Text('Decline'),
        ),
      ],
    );
  } else if (friendRequestStatus == 3) {
    return CircularProgressIndicator(); // Show loading indicator while performing action
  } else {
    return SizedBox(); // Return empty widget for unsupported states
  }
}


void sendFriendRequest() {
  // Implement API call to send friend request
}

void cancelFriendRequest() {
  // Implement API call to cancel friend request
}

void acceptFriendRequest() {
  // Implement API call to accept friend request
}

void declineFriendRequest() {
  // Implement API call to decline friend request
}
