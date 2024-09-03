import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import 'package:friendly_mobile_app/domain/fit_passport.dart';
import 'package:friendly_mobile_app/domain/fit_response.dart';
import 'package:friendly_mobile_app/services/fit_service.dart';
import 'package:friendly_mobile_app/utility/app_url.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:http/http.dart' as http;
import '../domain/user.dart';

class FitScreen extends StatefulWidget {
  const FitScreen({super.key});

  @override
  State<FitScreen> createState() => _FitScreenState();
}

class _FitScreenState extends State<FitScreen> {
  final FitService _fitService = FitService(baseUrl: 'https://api.example.com');
  int currentPage = 1;
  String searchText = '';
  int count = 0;
  bool isLoading = true;
  String error = '';
  List<FitPassport> passports = [];
  Timer? _debounce;
  List<User> dataList = [];

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchTextChanged(query);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPassports();
    fetchData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {

    var token = await UserPreferences().getToken();

    String uri = '${AppUrl.baseUrl}/User';
    // if (searchQuery != null && searchQuery.isNotEmpty) {
    //   uri += '&text=$searchQuery';
    // }

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> data = responseData['result'];
      final int countRes = responseData['count'];

      final List<User> items = data.map((data) {
        return User.fromJson(data);
      }).toList();

      setState(() {
        // count = countRes;
        dataList = items;
      });
    }
  }

  Future<void> fetchPassports() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      FitResponse response = await _fitService.fetchPassports(searchText, currentPage, 10);
      setState(() {
        passports = response.passports;
        count = response.count;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void searchTextChanged(String text) {
    setState(() {
      searchText = text;
      currentPage = 1;
    });

    fetchPassports();
  }

  Future<void> createCountry(int userId, bool isActive, DateTime expireDate) async {
    String token = await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> data = {'userId': userId, 'isActive': isActive, 'expireDate': expireDate.toIso8601String(),};

    final response = await http.post(
      Uri.parse('${AppUrl.baseUrl}/Fit'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(response.body.toString(), style: TextStyle(color: Colors.white)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Passport assigned successfully!', style: TextStyle(color: Colors.white)),
        ),
      );
      fetchPassports();
    }
  }



  Future<void> updateCountry(FitPassport fitPass) async {
    String token = await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> data = {'isActive': fitPass.isActive};

    final response = await http.put(
      Uri.parse('${AppUrl.baseUrl}/fit/' + fitPass.id.toString()),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update pasport');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Passport updated successfully!', style: TextStyle(color: Colors.white)),
        ),
      );
      fetchPassports();
    }
  }

  Future<void> deleteCountry(int countryId, bool isDeleted) async {
    String token = await UserPreferences().getToken();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.put(
      Uri.parse('${AppUrl.baseUrl}/country/delete?id=' + countryId.toString() + '&isDeleted=' + isDeleted.toString()),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update country');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Country updated successfully!', style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title:  Row(
            children: [
              Icon(Icons.document_scanner_rounded, color: Colors.white,),
              SizedBox(width: 10),
              Text('Fit passports', 
              style: TextStyle(color: Colors.white),
              ),
            ],
          ),
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
              ],
            ),
          ),
          Card(
      color: Colors.blue[50],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[800]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Info',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Search users by - full name, id, passport id',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 16),
          
          ],
        ),
      ),
    ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (error.isNotEmpty)
                    Center(child: Text(error))
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(
                            label: SizedBox(
                              width: 50,
                              child: Text('Pass ID'),
                            ),
                          ),
                           DataColumn(
                            label: SizedBox(
                              width: 50,
                              child: Text('User ID'),
                            ),
                          ),
                            DataColumn(
                            label: SizedBox(
                              width: 50,
                              child: Text('Name'),
                            ),
                          ),
                          // DataColumn(
                          //   label: SizedBox(
                          //     width: 150,
                          //     child: Text('Name'),
                          //   ),
                          // ),
                          DataColumn(
                            label: SizedBox(
                              width: 50,
                              child: Text('Active'),
                            ),
                          ),
                          // DataColumn(
                          //   label: SizedBox(
                          //     width: 100,
                          //     child: Text('Edit'),
                          //   ),
                          // ),
                            DataColumn(
                            label: SizedBox(
                              width: 150,
                              child: Text('Expire date'),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text('Date created'),
                            ),
                          ),

                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text('Edit'),
                            ),
                          ),
                        ],
                        rows: passports.map((country) {
                          return DataRow(
                            cells: [
                              DataCell(SizedBox(
                                width: 50,
                                child: Text(country.id.toString()),
                              )),
                               DataCell(SizedBox(
                                width: 50,
                                child: Text(country.user.id.toString()),
                              )),
                                DataCell(SizedBox(
                                width: 50,
                                child: Text(country.user.firstName.toString() +" " + country.user.lastName.toString()),
                              )),
                              DataCell(SizedBox(
                                width: 50,
                                child: Text(country.isActive.toString()),
                              )),
                                DataCell(SizedBox(
                                width: 150,
                                child: Text(country.expireDate.toString()),
                              )),
                              DataCell(SizedBox(
                                width: 150,
                                child: Text(country.dateCreated),
                                
                              )),
                              
                              DataCell(SizedBox(
                                width: 50,
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditCountryModal(context, country);
                                  },
                                ),
                              )),
                              // DataCell(SizedBox(
                              //   width: 50,
                              //   child: StatefulBuilder(
                              //     builder: (BuildContext context, StateSetter setState) {
                              //       return Switch(
                              //         value: country.deletedAt == null,
                              //         onChanged: (bool value) async {
                              //           setState(() {
                              //             country.deletedAt = !value ? DateTime.now().toIso8601String() : null;
                              //           });
                              //           await deleteCountry(country.id, !value);
                              //         },
                              //       );
                              //     },
                              //   ),
                              // )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  Pagination(
                    paginateButtonStyles: PaginateButtonStyles(),
                    prevButtonStyles: PaginateSkipButton(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    nextButtonStyles: PaginateSkipButton(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    onPageChange: (number) async {
                      setState(() {
                        currentPage = number;
                      });
                      await fetchPassports();
                    },
                    useGroup: false,
                    totalPage: (count / 10).ceil() == 0 ? 1 : (count / 10).ceil(),
                    show: (count / 10).ceil() <= 1 ? 0 : (count / 10).ceil() - 1,
                    currentPage: currentPage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateCountryModal(context);
        },
        tooltip: 'Create a passport',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateCountryModal(BuildContext context) {
  User? selectedUser;
  bool isActive = false;
  DateTime? _expireDate;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Create Passport'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('Set active status'),
                  subtitle: const Text(
                      "This will add admin permissions (admin role)."),
                  value: isActive,
                  onChanged: (newValue) {
                    setState(() {
                      isActive = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _expireDate ?? DateTime.now(),
                          firstDate:DateTime.now(),
                          lastDate: DateTime(2025),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _expireDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'Select expiry date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 10),
                            Text(
                              _expireDate != null
                                  ? '${_expireDate!.day}/${_expireDate!.month}/${_expireDate!.year}'
                                  : 'Select Expiry Date',
                            ),
                          ],
                        ),
                      ),
                    ),
                DropdownButtonFormField<User>(
                  value: selectedUser,
                  onChanged: (User? newValue) {
                    setState(() {
                      selectedUser = newValue!;
                    });
                  },
                  items: dataList.map<DropdownMenuItem<User>>((User country) {
                    return DropdownMenuItem<User>(
                      value: country,
                      child: Text(country.firstName),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'User'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await createCountry(selectedUser!.id, isActive, _expireDate!);
                  Navigator.of(context).pop();
                },
                child: Text('Create'),
              ),
            ],
          );
        },
      );
    },
  );
}

  void _showEditCountryModal(BuildContext context, FitPassport fitPassport) {
  bool isActive = true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Fit passport'),
        content: 
        Column(
              mainAxisSize: MainAxisSize.min,

          children: [

              CheckboxListTile(
                  title: const Text('Set active status'),
                  subtitle: const Text(
                      "This will add admin permissions (admin role)."),
                  value: isActive,
                  onChanged: (newValue) {
                    setState(() {
                      isActive = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
        ]),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
                await updateCountry(fitPassport);
                Navigator.of(context).pop();
              
            },
            child: Text('Update'),
          ),
        ],
      );
    },
  );
}

}

