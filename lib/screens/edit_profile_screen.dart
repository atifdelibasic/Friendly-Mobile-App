import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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

print("user date");
print(widget.user.birthDate);
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
      String token =  await UserPreferences().getToken();

      final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/hobby'),
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
            _hobbyMap = Map.fromIterable(hobbies, key: (hobby) => hobby.id, value: (hobby) => hobby.title);
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

  Future<void> _getUserHobbies() async {
    try {
      String token =  await UserPreferences().getToken();

      final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/User/${widget.user.id}/hobbies'),
        headers: {
          'Authorization': 'Bearer ' + token,
        },
      );

      if (response.statusCode == 200) {
         final List<dynamic> responseData = jsonDecode(response.body);

          setState(() {
              final List<Hobby> items = responseData.map((responseData) {
            return Hobby.fromJson(responseData);
          }).toList();
    _selectedHobbies = items.map((hobby) => hobby.id).toList();
          });
        } 
    } catch (e) {
      print('Error fetching hobby categories: $e');
    }
  }

  void _updateProfile() async {
    print("date of brith");
    print(_dateOfBirth.toString());
    try {
      String token = await UserPreferences().getToken();

        print(_selectedHobbies);

      final response = await http.put(
        Uri.parse("${AppUrl.baseUrl}/user/update/${widget.user.id}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'description': _descriptionController.text,
          'imagePath': imageUrl,
          'hobbyIds': _selectedHobbies,
          'birthDate': _dateOfBirth?.toIso8601String()
        }),
      );

      if (response.statusCode == 200) {
        widget.user.firstName = _firstNameController.text;
        widget.user.lastName = _lastNameController.text;
        widget.user.description = _descriptionController.text;
        widget.user.birthDate = _dateOfBirth?.toIso8601String();

        Provider.of<UserProvider>(context, listen: false).setUser(widget.user);

        Navigator.pop(context, true); // Navigate back with success flag
      } else {
        print(response.statusCode);
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print(e);
      print('Error updating profile: $e');
      // Handle error
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
      ),
      body: Padding(
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
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            // Dropdown list of hobbies
            Text('Select Hobbies:'),
            DropdownButtonFormField<int>(
              value: null,
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
            ),
            SizedBox(height: 20),
            // Display selected hobbies
            Text(
              'Selected Hobbies: ${_selectedHobbies.map((id) => _hobbyMap[id]).join(", ")}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
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
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update profile'),
            ),
          ],
        ),
      ),
    );
  }
}
