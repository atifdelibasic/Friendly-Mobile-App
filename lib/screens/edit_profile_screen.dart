import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friendly_mobile_app/domain/city_response.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../domain/city.dart';
import '../domain/country.dart';
import '../domain/country_response.dart';
import '../domain/hobby.dart';
import '../domain/user.dart';
import '../providers/user_provider.dart';
import '../services/city_service.dart';
import '../services/country_service.dart';
import '../utility/app_url.dart';

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
  List<Hobby> recommendedHobbies = [];
  final CountryService _countryService = CountryService(baseUrl: 'https://api.example.com');
  final CityService _cityService = CityService(baseUrl: 'https://api.example.com');

  int count = 0;

  DateTime? _dateOfBirth;
  List<int> _selectedHobbies = [];
  late Map<int, String> _hobbyMap = {};

  late String imageUrl = "";
  List<Country> countries = [];
  List<City> cities = [];

  int? _selectedCountryId;
  int? _selectedCityId;

  @override
  void initState() {
    super.initState();

   
    _getHobbies();
    _getUserHobbies();
    _getRecommendedHobbies();
    fetchCountries();

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

  Future<void> _getRecommendedHobbies() async {
    try {
      String token = await UserPreferences().getToken();
      var user = await UserPreferences().getUser();

      final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/api/Recommendations/predict?userId=${user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);

      setState(() {
        recommendedHobbies = responseData.map((categoryJson) => Hobby.fromJson(categoryJson)).toList();
      });
    } else {
      print('Failed to fetch recommended hobbies: ${response.body}');
      }
    } catch (e) {
      print('Error fetching recommended hobbies: $e');
    }
  }

  Future<void> fetchCities() async {
  CityResponse response = await _cityService.fetchCities("", _selectedCountryId!);
      setState(() {
        cities = response.cities;
        count = response.count;
      });

  }
  void _onCountrySelected(int countryId) {
  setState(() {
    _selectedCityId = null;
    _selectedCountryId = countryId;
    fetchCities();
  });
}

  Future<void> fetchCountries() async {

      CountryResponse response = await _countryService.fetchCountries("", 1, 20);
      setState(() {
        countries = response.countries;
        count = response.count;

        _selectedCountryId = widget.user.countryId;
        fetchCities();
        _selectedCityId = widget.user.cityId;

      });
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
        final List<Hobby> items = responseData.map((responseData) {
          return Hobby.fromJson(responseData);
        }).toList();

        setState(() {
          _selectedHobbies = items.map((hobby) => hobby.id).toList();
        });
      }
    } catch (e) {
      print('Error fetching user hobbies: $e');
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
          'cityId': _selectedCityId,
        }),
      );

      if (response.statusCode == 200) {
        widget.user.firstName = _firstNameController.text;
        widget.user.lastName = _lastNameController.text;
        widget.user.description = _descriptionController.text;
        widget.user.birthDate = _dateOfBirth?.toIso8601String();
        widget.user.token = token;
        widget.user.cityId = _selectedCityId;
        widget.user.countryId = _selectedCountryId;

        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String? imagePath = responseBody['profileImageUrl'];
        widget.user.profileImage = imagePath != null && imagePath != "" ? "${AppUrl.baseUrl}/images/$imagePath" : 'https://ui-avatars.com/api/?rounded=true&name=${widget.user.firstName}+${widget.user.lastName}&size=300';


        Provider.of<UserProvider>(context, listen: false).setUser(widget.user);
        await UserPreferences().saveUser(widget.user);

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
      print('Error updating profile: $e');
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
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
         leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                    if ((imageUrl.isNotEmpty))

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
            SizedBox(height: 10),
               Center(child:  Text("Tap to upload image")),
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
                    DropdownButtonFormField<int>(
                      value: _selectedCountryId,
                      onChanged: (int? value) {
                        setState(() {
                          if (value != null) {
                              _onCountrySelected(value);
                          }
                        });
                      },
                      items: countries.map((Country country) {
                        return DropdownMenuItem<int>(
                          value: country.id,
                          child: Row(
                            children: [
                              if (_selectedCountryId == country.id)
                                Icon(Icons.check),
                              SizedBox(width: 8),
                              Text(country.name),
                            ],
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "Country",
                      ),
                    ),
                    SizedBox(height: 20,),
                    DropdownButtonFormField<int>(
                      value: _selectedCityId,
                      onChanged: (int? value) {
                        setState(() {
                          if (value != null) {
                              // _onCountrySelected(value);
                              setState(() {
                              _selectedCityId = value;
                                
                              });
                          }
                        });
                      },
                      items: cities.map((City city) {
                        return DropdownMenuItem<int>(
                          value: city.id,
                          child: Row(
                            children: [
                              if (_selectedCityId == city.id)
                                Icon(Icons.check),
                              SizedBox(width: 8),
                              Text(city.name),
                            ],
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "City",
                      ),
                    ),
                  //   DropdownButtonFormField<int>(
                  //   value: _selectedCityId,
                  //   onChanged: (int? value) {
                  //     setState(() {
                  //       _selectedCityId = value;
                  //     });
                  //   },
                  //   items: cities.map((City city) {
                  //     return DropdownMenuItem<int>(
                  //       value: city.id,
                  //       child: Row(
                  //         children: [
                  //           if (_selectedCityId == city.id)
                  //             Icon(Icons.check),
                  //           SizedBox(width: 8),
                  //           Text(city.name),
                  //         ],
                  //       ),
                  //     );
                  //   }).toList(),
                  //   decoration: InputDecoration(
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     labelText: "City",
                  //   ),
                  // ),
                  SizedBox(height: 20,),
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
                        labelText: "Hobby",
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
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recommended Hobbies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Information'),
                      content: Text('The code implements a recommender system using matrix factorization with Microsoft ML.NET. The recommender system aims to predict hobbies that a user might be interested in based on their interactions with hobbies categorized by different categories.'),
                      actions: [
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),

        SizedBox(height: 5),
         Text('Tap on info icon for more information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.red)),
        SizedBox(height: 5),
            recommendedHobbies.isEmpty ? Text("No hobbies to recommend") : Container(),

        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: recommendedHobbies.map((hobby) {
            return GestureDetector(
              onTap: () {
                _onHobbySelected(hobby.id);
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(hobby.title, style: TextStyle(fontSize: 16)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),)),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Update Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
