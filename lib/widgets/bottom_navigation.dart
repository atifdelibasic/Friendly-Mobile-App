
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class BottomNavigation extends StatelessWidget {
  final int index;
  const BottomNavigation({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(FeatherIcons.home, color: Colors.grey),
                onPressed: () {
                  Navigator.popAndPushNamed(
                    context,
                    '/feed',
                  );
                },
              ),
              Text(
                'Home',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.location_on),
                onPressed: () {
                  Navigator.popAndPushNamed(
                    context,
                    "/nearby"
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
                  // Define your action for Requests here
                },
              ),
              Text('Requests'),
            ],
          ),
        ],
      ),
    );
  }
}
