
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:friendly_mobile_app/screens/requests.dart';
import '../screens/add_post_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int index;
  final BuildContext context;
  const BottomNavBar({Key? key, required this.index,  required this.context}) : super(key: key);

  void goScreen(int index) {
    switch(index) {
      case 0: 
      Navigator.popAndPushNamed(context, "/feed");
      break;
      case 1: 
      Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPostScreen()),
              );
              break;
      case 2:
      Navigator.popAndPushNamed(context, "/nearby");
      break;
      case 3:
      Navigator.push(
                          context,
        MaterialPageRoute(
                            builder: (context) => RequestsPage(),
                          ));
      break;

    }
  }

  @override
  Widget build(BuildContext context) {


  return BottomNavigationBar(
    currentIndex: index,
    selectedItemColor: Colors.black,
    showSelectedLabels: true,
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
    onTap: (int index) {
      goScreen(index);
    },
    showUnselectedLabels: true,
    items: const [
      BottomNavigationBarItem(icon: Icon(FeatherIcons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(FeatherIcons.plusSquare), label: "Post"),
      BottomNavigationBarItem(icon: Icon(FeatherIcons.map), label: "Nearby"),
      BottomNavigationBarItem(icon: Icon(FeatherIcons.users), label: "Requests"),
  ]);
  }
}
