import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/screens/user_profile.dart';
import 'package:friendly_mobile_app/utility/app_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utility/shared_preference.dart';
import '../domain/user.dart'; // Import User class

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  late Future<List<dynamic>> _futureRequests;

  @override
  void initState() {
    super.initState();
    _futureRequests = _fetchFriendRequests();
  }

  Future<List<dynamic>> _fetchFriendRequests() async {
    try {
      String token = await UserPreferences().getToken();

      final response = await http.get(
        Uri.parse("${AppUrl.baseUrl}/Profiles/friend-requests"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Decode the response body
        final List<dynamic> requestsJson = json.decode(response.body);
        return requestsJson;
      } else {
        // Handle error response
        throw Exception('Failed to fetch friend requests');
      }
    } catch (error) {
      // Handle network or other errors
      throw Exception('Failed to fetch friend requests: $error');
    }
  }

  Future<void> _refreshRequests() async {
    setState(() {
      _futureRequests = _fetchFriendRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
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
              // Display the list of friend requests
              final List<dynamic> requests = snapshot.data as List<dynamic>;
              if (requests.isEmpty) {
                return Text('No requests to show.');
              } else {
                // Display the list of friend requests
                return RefreshIndicator(
                  onRefresh: _refreshRequests,
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final user = User.fromJson(request['user']); // Convert to User object

                      return ListTile(
                        onTap: () {
                          // Navigate to the user profile page when tapped
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
                        title: Text('${user.firstName} ${user.lastName}'),
                        subtitle: Text(user.email),
                        // Add an icon to indicate friend request
                        trailing: Icon(Icons.person_add),
                        // You can add more information about the user here
                        // Customize this ListTile as needed
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
 