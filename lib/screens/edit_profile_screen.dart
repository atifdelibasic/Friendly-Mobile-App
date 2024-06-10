import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/hobby.dart';
import '../domain/user.dart';
import '../providers/user_provider.dart';
import '../utility/app_url.dart';
import '../utility/shared_preference.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _descriptionController;
  List<Hobby> hobbies = []; 
  DateTime? _dateOfBirth;
  List<int> _selectedHobbies = [];
  late Map<int, String> _hobbyMap = {}; 

  late String imageUrl = "";

  @override
  void initState() {
    super.initState();

    _getHobbies();
    _getUserHobbies();

    _firstNameController =
        TextEditingController(text: widget.user.firstName);
    _lastNameController =
        TextEditingController(text: widget.user.lastName);
    _descriptionController =
        TextEditingController(text: widget.user.description);

    _dateOfBirth = DateTime.parse(widget.user.birthDate ?? "");
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _getHobbies() async {
    try {
      String token = await UserPreferences().getToken();

      final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/hobby'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('result')) {
          List<dynamic> categories = responseData['result'];

          setState(() {
            hobbies = categories.map((categoryJson) => Hobby.fromJson(categoryJson)).toList();
            _hobbyMap = Map.fromIterable(hobbies, key: (hobby) => hobby.id, value: (hobby) => hobby.title);
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

  Future<void> _getUserHobbies() async {
    try {
      String token = await UserPreferences().getToken();

      final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/User/${widget.user.id}/hobbies'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        print("response data");
        print(responseData);
        final List<Hobby> items = responseData.map((responseData) {
          return Hobby.fromJson(responseData);
        }).toList();

        setState(() {
          _selectedHobbies = items.map((hobby) => hobby.id).toList();
          print("selected hobbies" + _selectedHobbies.toString());
        });
      }
    } catch (e) {
      print('Error fetching hobby categories: $e');
    }
  }

  void _updateProfile() async {
    try {
      String token = await UserPreferences().getToken();

      final response = await http.put(
        Uri.parse("${AppUrl.baseUrl}/user/update/${widget.user.id}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': 1,
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'description': _descriptionController.text,
          'imagePath': imageUrl,
          'hobbyIds': _selectedHobbies,
          'birthDate': _dateOfBirth?.toIso8601String(),
          'profileImageUrl': widget.user.profileImage,
          'cityId': null,
        }),
      );

      if (response.statusCode == 200) {
        
        widget.user.firstName = _firstNameController.text;
        widget.user.lastName = _lastNameController.text;
        widget.user.description = _descriptionController.text;
        widget.user.birthDate = _dateOfBirth?.toIso8601String();
        widget.user.token = token;

        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String? imagePath = responseBody['profileImageUrl'];
        widget.user.profileImage = imagePath != null && imagePath != "" ? "${AppUrl.baseUrl}/images/$imagePath" : 'https://ui-avatars.com/api/?rounded=true&name=ad&size=300';
        
        print('Image Path: $imagePath');

        Provider.of<UserProvider>(context, listen: false).setUser(widget.user);
        UserPreferences().saveUser(widget.user);


        Navigator.pop(context, true); 
         Fluttertoast.showToast(
          msg: 'Profile updated successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception('Failed to update profile ' + response.statusCode.toString());
      }
    } catch (e) {
      print("eeee");
      print(e);
      print('Error updating profile: $e');
      // Handle error
    }
  }
  String getSelectedHobbiesTitle() {
  if (_selectedHobbies.isEmpty) {
    return 'Select Hobbies';
  } else {
    return _selectedHobbies
        .map((id) => _hobbyMap[id]!)
        .join(', '); // Concatenate selected hobby titles
  }
}
  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      setState(() {
        imageUrl = base64Image;
      });
    }
  }

  void _removeImage() {
    setState(() {
      imageUrl = "";
    });
  }

  void _onHobbySelected(int hobbyId) {
    setState(() {
      if (_selectedHobbies.contains(hobbyId)) {
        _selectedHobbies.remove(hobbyId);
      } else {
        _selectedHobbies.add(hobbyId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: InkWell(
                onTap: () async {
                  await _getImage();
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: imageUrl.isNotEmpty
                          ? MemoryImage(
                              base64Decode(imageUrl),
                            )
                          : NetworkImage(widget.user.profileImage)
                              as ImageProvider,
                    ),
                    if (imageUrl.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Date of Birth Input
                    Text('Date of Birth:'),
                    InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _dateOfBirth ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dateOfBirth = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'Select Date of Birth',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 10),
                            Text(
                              _dateOfBirth != null
                                  ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                  : 'Select Date of Birth',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Select Hobbies:'),
                    SizedBox(height: 10),
                    DropdownButtonFormField<int>(
  value: _selectedHobbies.isNotEmpty ? _selectedHobbies[0] : null,
  onChanged: (int? value) {
    setState(() {
      if (value != null) {
        _onHobbySelected(value);
      }
    });
  },
  items: hobbies.map((Hobby hobby) {
    return DropdownMenuItem<int>(
      value: hobby.id,
      child: Row(
        children: [
          if (_selectedHobbies.contains(hobby.id))
            Icon(Icons.check),
          SizedBox(width: 8),
          Text(hobby.title),
        ],
      ),
    );
  }).toList(),
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    labelText:"Select a hobby", // Use the method to get the selected hobbies title
  ),
),

                    SizedBox(height: 20),
                  Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedHobbies.map((id) {
                  final hobby = _hobbyMap[id];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedHobbies.remove(id);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hobby!,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 8.0),
                          Icon(Icons.close, size: 16),
                        ],
                      ),
                    ),
                  );
                  }).toList(),
                  )

                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
