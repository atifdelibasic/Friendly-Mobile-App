import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/domain/hobby.dart';
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
import 'edit_profile_screen.dart';

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
  late int id = 0;
  late int friendId = 0;
  List<Hobby> hobbies = [];
  bool isLoadingFriendStatus = true;

  void fetchHobbies() async {
     String token =  await UserPreferences().getToken();
    final uri = '${AppUrl.baseUrl}/User/${widget.user.id}/hobbies';
     final response = await http.get(
        Uri.parse(uri),
         headers: {
          'Authorization': 'Bearer $token', 
        },
      );

       if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        final List<Hobby> items = responseData.map((responseData) {
            return Hobby.fromJson(responseData);
          }).toList();

        hobbies = items;
       }

  }

  void fetchFriendRequestStatus() async {
    setState(() {
      isLoadingFriendStatus = true;
    });
    try {
      String token = await UserPreferences().getToken();
      final response = await http.get(
        Uri.parse("${AppUrl.baseUrl}/Profiles/${widget.user.id}/friendship-status"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print(response.statusCode);
      if(response.body == "") {
        setState(() {
        friendRequestStatus = 0;
        friendId = 0;
        id = 0;
        isLoadingFriendStatus = false;
        });
        return;
      }
      Map<String, dynamic> responseData = json.decode(response.body);
    
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Parse the response and extract friend request status
        setState(() {
      int status = responseData['status'];
         friendRequestStatus = status;
         id = responseData['id'];
         friendId = responseData['user']['id'];
         isLoadingFriendStatus = false;

        });
      } else {
        throw Exception('Failed to fetch friend request status');
      }
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
    final uri = '${AppUrl.baseUrl}/Post/user?UserId=${widget.user.id}&limit=$limit${_posts.isNotEmpty ? '&cursor=${_posts.last.id}' : ''}';
     final response = await http.get(
        Uri.parse(uri),
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
    fetchHobbies();
    fetchFriendRequestStatus();

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
    fetchFriendRequestStatus();
    fetchHobbies();
  }

  void _navigateToEditProfile() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditProfileScreen(user: widget.user),
    ),
  );
}


 @override
Widget build(BuildContext context) {

    User? user = Provider.of<UserProvider>(context, listen: true).user;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.deepPurple,
  title: Text('User Profile', style:  TextStyle(color: Colors.white),),
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white,),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
  actions: <Widget>[
    if (user?.id == widget.user.id) // Replace "condition" with your actual condition
      IconButton(
        icon: Icon(Icons.edit, color: Colors.white,),
        onPressed: _navigateToEditProfile,
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
                            "${widget.user.firstName} ${widget.user.lastName}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(widget.user.email),
                        Divider(),
                       Center(
                        child: Column(
                          children: [
                            Text(
                              "Description", // Label indicating the description section
                              style: TextStyle(
                                fontSize: 16, // Adjust the font size as needed
                                fontWeight: FontWeight.bold, // Optionally, make the label bold
                              ),
                            ),
                            SizedBox(height: 8), // Add some space between the label and the description
                            Text(
                              widget.user.description == "" ? "No data" : widget.user.description,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                        Divider(),
                       Text(
                              "Hobbies & intrests",
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                              ),
                            ),

                      Column(
      children: [
       Center(
  child: Center(
  child: Column(
    children: [
      Center( 
        child: ListView.builder(
          shrinkWrap: true, 
          itemCount: hobbies.length,
          itemBuilder: (BuildContext context, int innerIndex) {
            return Center(
              child: Text(hobbies[innerIndex].title),
            );
          },
        ),
      ),
    ],
  ),
)
),
      ]),
        if(hobbies.isEmpty) 
        Center(child: Text("No hobbies or intrests"),),

                         if(user?.id != widget.user.id)  
                         buildFriendRequestButton(),
                         if(user?.id != widget.user.id) 
                         ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChatScreen(recipientId: widget.user.id, recipientProfileImage: widget.user.profileImage, fullName: widget.user.fullName,)),
                            );
                          },
                          child:Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.chat_rounded),
                              SizedBox(width: 8), 
                              Text('Start Chat'),
                            ],
                          ),
                        ),
                        Divider(), 
                      ],
                    ),
                  );
                } else if ((index <= _posts.length)) {
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

 Widget buildFriendRequestButton() {
  if(isLoading ) {
    return CircularProgressIndicator();
  }

  if (friendRequestStatus == 0) {
    return ElevatedButton(
      onPressed: () {
        sendFriendRequest();
      },
       child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.add_rounded),
        SizedBox(width: 8), 
        Text('Send friend request'),
      ],
    ),
    );
  } else if (friendRequestStatus == 1 && widget.user.id != friendId) {
    return ElevatedButton(
      onPressed: () {
        cancelFriendRequest();
      },
      child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.cancel),
        SizedBox(width: 8), 
        Text('Cancel friend request'),
      ],
    ),
    );
  } else if (friendRequestStatus == 1 && widget.user.id == friendId) {
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
  } else if (friendRequestStatus == 2) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      DropdownButton<String>(
        value: 'Friends',
        icon: Icon(Icons.arrow_downward),
        onChanged: (String? newValue) {
        },
        items: <DropdownMenuItem<String>>[
          DropdownMenuItem<String>(
            value: 'Friends',
            child: Text('Friends'),
          ),
          DropdownMenuItem<String>(
            value: 'Remove Friend',
            child: ElevatedButton(
              onPressed: () {
                cancelFriendRequest();
              },
              child: Text('Remove Friend'),
            ),
          ),
        ],
      ),
    ],
  );
}
 else {
    return SizedBox(); 
  }
}


void sendFriendRequest() async {
   String token =  await UserPreferences().getToken();

  final Map<String, String> headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

   final Map<String, dynamic> body = {"id":widget.user.id};

  await http.post(
      Uri.parse("${AppUrl.baseUrl}/profiles/${widget.user.id}/friend-requests"),
      headers: headers,
      body: jsonEncode(body),
    );
    fetchFriendRequestStatus();
}

void cancelFriendRequest() async{
   String token =  await UserPreferences().getToken();

  final Map<String, String> headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

   final Map<String, dynamic> body = {};

   await http.put(
      Uri.parse("${AppUrl.baseUrl}/friend-request/$id/decline"),
      headers: headers,
      body: jsonEncode(body),
    );
     fetchFriendRequestStatus();
}

void acceptFriendRequest() async{
  String token =  await UserPreferences().getToken();

  final Map<String, String> headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

   final Map<String, dynamic> body = {};

  await http.put(
      Uri.parse(AppUrl.baseUrl + "/friend-request/$id/accept"),
      headers: headers,
      body: jsonEncode(body),
    );
     fetchFriendRequestStatus();

}

void declineFriendRequest() {
  // Implement API call to decline friend request
}

}
 // Function to build friend request button based on friendRequestStatus
