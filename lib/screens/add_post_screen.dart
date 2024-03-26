import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/domain/hobby.dart';
import 'package:friendly_mobile_app/domain/hobbyCategory.dart';
import 'package:friendly_mobile_app/screens/feed.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../utility/shared_preference.dart';


class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  TextEditingController descriptionController = TextEditingController();
  String imageUrl = '';
  int? selectedCategoryId; 
  int? selectedHobbyId; 
  double? latitude;
  double? longitude;
  bool isLocationLoading = false;

  List<HobbyCategory> hobbyCategories = []; 
  List<Hobby> hobbies = []; 

  Future<void> _fetchInitialData() async {
    await _getHobbyCategories();
  }

  Future<void> _getHobbyCategories() async {
    
    try {

    String token =  await UserPreferences().getToken();

      final response = await http.get(
        Uri.parse('https://localhost:7169/HobbyCategory'),
        headers: {
          'Authorization': 'Bearer ' + token ,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('result')) {
          List<dynamic> categories = responseData['result'];

          setState(() {
            hobbyCategories = categories.map((categoryJson) => HobbyCategory.fromJson(categoryJson)).toList();
          });
        } else {
          print('Missing "result" key in the response');
        }
      } else {
        print('Failed to fetch hobby categories: ${response.body}');
      }
    } catch (e) {
      print('Error fetching hobby categories: $e');
    }
  }

  Future<void> _getHobbies(int categoryId) async {

    try {
    String token =  await UserPreferences().getToken();

      final response = await http.get(
        Uri.parse('https://localhost:7169/hobby'),
        headers: {
          'Authorization': 'Bearer ' + token,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('result')) {
          List<dynamic> categories = responseData['result'];

          setState(() {
            hobbies = categories.map((categoryJson) => Hobby.fromJson(categoryJson)).toList();
            print(hobbies);
          });
        } else {
          print('Missing "result" key in the response');
        }
      } else {
        print('Failed to fetch hobby categories: ${response.body}');
      }
    } catch (e) {
      print('Error fetching hobby categories: $e');
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      setState(() {
        imageUrl = base64Image;
      });
    }
  }

  Future<void> _getLocation() async {
     setState(() {
      isLocationLoading = true;
    });
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    
    try {
     
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        isLocationLoading = false;
      });

      Fluttertoast.showToast(
        msg: 'Location set successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
       setState(() {
          isLocationLoading = false;
        });
      print('Error getting location: $e');
    }
  }

  void _clearLocation() {
    setState(() {
      latitude = null;
      longitude = null;
    });
  }

  Future<void> _createPost() async {
    try {
    String token =  await UserPreferences().getToken();

      final response = await http.post(
        Uri.parse('https://localhost:7169/Post'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer '  + token,
        },
        body: jsonEncode({
          'description': descriptionController.text,
          'imagePath': imageUrl,
          'hobbyId': selectedHobbyId,
          'longitude': longitude,
          'latitude': latitude,
        }),
      );

      if (response.statusCode == 200) {
        print('Post created successfully');
        
         Fluttertoast.showToast(
        msg: 'Post created successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Feed()),
      );
      } else {
        print('Failed to create post: ${response.body}');
      }
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

@override
Widget build(BuildContext context) {
  bool isButtonEnabled = selectedHobbyId != null && descriptionController.text.isNotEmpty;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text('Add Post'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () async {
              await _getImage();
            },
            child: Text('Pick Image'),
          ),
          SizedBox(height: 16.0),
          imageUrl.isNotEmpty
              ? Image.memory(
                  base64Decode(imageUrl),
                  height: 100.0,
                  fit: BoxFit.cover,
                )
              : Container(),
          SizedBox(height: 16.0),
          DropdownButton<int?>(
            value: selectedCategoryId,
            onChanged: (value) {
              setState(() {
                selectedCategoryId = value;
                selectedHobbyId = null;
                if (selectedCategoryId != null) {
                  _getHobbies(selectedCategoryId!);
                } else {
                  hobbies = [];
                  selectedHobbyId = null;
                }
              });
            },
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('Select Hobby Category'),
              ),
              ...hobbyCategories
                  .map((category) => DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.name),
                      ))
                  .toList(),
            ],
          ),
          SizedBox(height: 16.0),
          DropdownButton<int?>(
            value: selectedHobbyId,
            onChanged: (value) {
              setState(() {
                selectedHobbyId = value;
              });
            },
            items: hobbies
                .map((hobby) => DropdownMenuItem<int?>(
                      value: hobby.id,
                      child: Text(hobby.title),
                    ))
                .toList(),
            hint: Text('Select Hobby'),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: descriptionController,
            onChanged: (value) {
              setState(() {
                // Update the state when the description changes
              });
            },
            decoration: InputDecoration(
              labelText: 'Description',
              errorText: descriptionController.text.isEmpty ? 'Description is required' : null,
            ),
          ),
           SizedBox(height: 16.0),
            isLocationLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 8.0),
                      Text('Fetching Location...'),
                    ],
                  )
                : latitude != null && longitude != null
                    ? Column(
                        children: [
                          Text(
                            'Location set: Latitude: $latitude, Longitude: $longitude',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: _clearLocation,
                            child: Text('Clear Location'),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Posts will be available to users with similar interests nearby.',
                            style: TextStyle(fontSize: 14.0, color: Colors.grey),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          await _getLocation();
                        },
                        child: Text('Set Location'),
                      ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () {
                      _createPost();
                    }
                  : null,
              child: Text('Post'),
            ),
          ],
      ),
    ),
  );
}
}