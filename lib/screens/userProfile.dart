import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;

  UserProfilePage({required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // Placeholder data for demonstration purposes
  String firstName = 'John';
  String lastName = 'Doe';
  int numberOfFriends = 50;
  bool isFriend = false; // Change this to true if the users are already friends

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/profile_picture.jpg'), // Add your profile picture
            ),
            SizedBox(height: 20),
            Text(
              '$firstName $lastName',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Friends: $numberOfFriends'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle message button click
                print('Message button clicked');
              },
              child: Text('Message'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Handle friend status button click
                print('Friend Status button clicked');
              },
              child: Text(isFriend ? 'Friends' : 'Add Friend'),
            ),
          ],
        ),
      ),
    );
  }
}
