import 'package:flutter/material.dart';

class UserProfilePage1 extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage1> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
                SizedBox(height: 10),
                Text(
                  'Your Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  tabs: [
                    Tab(text: 'Posts'),
                    Tab(text: 'About Me'),
                    // Add more tabs as needed
                  ],
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      // Placeholder for Posts
                      Center(
                        child: Text('Posts Data'),
                      ),
                      // Placeholder for About Me
                      Center(
                        child: Text('About Me Data'),
                      ),
                      // Add more placeholders for additional tabs
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
