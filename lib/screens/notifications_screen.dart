import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/screens/user_profile.dart';
import 'package:friendly_mobile_app/utility/app_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utility/shared_preference.dart';
import '../domain/user.dart';
import '../utility/time.dart'; // Import User class

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<dynamic>> _futureRequests;

  @override
  void initState() {
    super.initState();
    _futureRequests = _fetchNotifications();
  }

  Future<List<dynamic>> _fetchNotifications() async {
    try {
      String token = await UserPreferences().getToken();
      User user = await UserPreferences().getUser();

      final response = await http.get(
        Uri.parse("${AppUrl.baseUrl}/Notifications?UserId=${user.id}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> requestsJson = json.decode(response.body);
        return requestsJson;
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (error) {
      throw Exception('Failed to fetch friend requests: $error');
    }
  }

  Future<void> _refreshRequests() async {
    setState(() {
      _futureRequests = _fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: _futureRequests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final List<dynamic> requests = snapshot.data as List<dynamic>;
              if (requests.isEmpty) {
                return Center(
                  child: Text('No notifications to show.'),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: _refreshRequests,
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final user = User.fromJson(request['sender']); 
                      String dateCreated = request['dateCreated']; 

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfilePage(user: user),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.profileImage),
                          ),
                          title: Text(
                            '${user.firstName} ${user.lastName} liked your post ' + calculateTimeAgo(dateCreated),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(user.email),
                          trailing: Icon(Icons.thumb_up_rounded),
                        ),
                      );
                    },
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
