import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/domain/user.dart';
import 'package:friendly_mobile_app/feedback_dialog.dart';
import 'package:friendly_mobile_app/rate_app_dialog.dart';
import 'package:friendly_mobile_app/screens/placeholders.dart';
import 'package:friendly_mobile_app/screens/user_profile.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:friendly_mobile_app/widgets/post_card.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import '../domain/post.dart';
import '../providers/user_provider.dart';
import '../utility/app_url.dart';
import '../widgets/bottom_navigation_bar.dart';
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
  bool locationFetched = false;
  final controller = ScrollController();
  List<Post> _posts = [];
  double? latitude;
  double? longitude;
  bool isLocationLoading = false;
  bool loadUser = false;

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  void getUser() {
    Future.delayed(Duration.zero, () async {
      Future<User> getUserData() => UserPreferences().getUser();
      Provider.of<UserProvider>(context, listen: false).setUser(await getUserData());

      setState(() {
        loadUser = true;
      });

    });
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

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch location here
  WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationAndFetch();
    });

  }

  Future<void> _initializeLocationAndFetch() async {
    if(!locationFetched) {
  _showLoadingIndicator(context, 'Fetching Location...');
    await _getLocation();
    await fetch();
    Navigator.pop(context); 
    locationFetched = true;
    }

  }
    void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FeedbackDialog();
      },
    );
  }

  void _showRateAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RateAppDialog();
      },
    );
  }

  Future<void> _getLocation() async {
    print("get location a");
  // setState(() {
  //   isLocationLoading = true;
  // });

  // _showLoadingIndicator(context, 'Fetching Location...');

  LocationPermission permission = await Geolocator.requestPermission();
   if (permission == LocationPermission.denied) {
     permission = await _geolocatorPlatform.requestPermission();
   }
   print("tu samW");
  
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    print(position.longitude);
    print(position.latitude);


    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      // isLocationLoading = false;
    });

    // _hideLoadingIndicator(context);

  } catch (e) {
    setState(() {
      isLocationLoading = false;
    });
   // _hideLoadingIndicator(context);
    print('Error getting location: $e');
  }
}

Future<void> fetch() async {
  
  
    if (isLoading) return;

    const limit = 5;

    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2));

    String token = await UserPreferences().getToken();

     final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/post/nearby?longitude=${longitude}&latitude=${latitude}&limit=$limit${_posts.isNotEmpty ? '&cursor=${_posts.last.id}' : ''}'),
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
          print("rezultat " + items.length.toString());

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

  Future<void> _refreshFeed() async {
   
    setState(() {
      isLoading = false;
      hasMore = true;
      _posts.clear();
    });

    fetch();
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
              await UserPreferences().removeUser();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text("Logout"),
          ),
        ],
      );
    },
  );
}

 void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Nearby posts"),
content: Text(
  "This page shows posts from users who are nearby and share the same hobbies as you. It covers a 10 km radius, but for testing purposes, it's much larger. The Haversine Formula is used for calculations. Quick info: the database seed is random, so if no posts are shown, log in to another account or create your own posts to see them here. Cheers! :D"
),          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var user1 = Provider.of<UserProvider>(context, listen: true).user;

    return Scaffold(
     appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        leadingWidth: 45,
        leading:InkWell(
          
            onTap: () {
               Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfilePage(user: user1!)),
                      );
            },
         child: SizedBox(
          height: 100,
          width:10,
         child: Padding(
      padding: EdgeInsets.only(left: 10.0),  
      child: 
      user1 == null ?  CircleAvatar():
      CircleAvatar(
        backgroundImage: NetworkImage(user1.profileImage),
      ),
    ),
  ), ),
        actions: [
            IconButton(
            onPressed: () {
              _showInfoDialog(context);
            },
            icon: const Icon(Icons.info_outline, color: Colors.white),
          ),
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
          icon: const Icon(Icons.search, color: Colors.white)),

          // user profile
         PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: "logout",
                child: Row(
                  children: const [
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
                  children: const [
                    Icon(Icons.feedback,
                        color: Colors.grey), 
                    SizedBox(width: 8), 
                    Text("Feedback"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "rate",
                child: Row(
                  children: const [
                    Icon(Icons.star, color: Colors.grey), 
                    SizedBox(width: 8), 
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
        index: 2,
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
