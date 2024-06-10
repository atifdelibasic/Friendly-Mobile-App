import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:http/http.dart' as http;
import 'utility/app_url.dart';

class RateAppDialog extends StatefulWidget {
  @override
  _RateAppDialogState createState() => _RateAppDialogState();
}

class _RateAppDialogState extends State<RateAppDialog> {
  double _rating = 0;
  bool _isSubmitting = false;

  void _submitRating(BuildContext context) async {
    setState(() {
      _isSubmitting = true;
    });
    String token = await UserPreferences().getToken();
  var user = await UserPreferences().getUser();
  String url = "${AppUrl.baseUrl}/rateapp";

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  Map<String, dynamic> body = {
    'userId': user.id,
     'rating' : _rating
  };

  var response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body.isNotEmpty ? jsonEncode(body) : null,
  );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Thanks for rating our app $_rating stars!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text("Rate This App"),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We hope you enjoy using our app. Please rate it below:",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        SizedBox(
          width: 80,
          child: ElevatedButton(
            onPressed: _isSubmitting || _rating == 0 ? null : () => _submitRating(context),
            style: ElevatedButton.styleFrom(
              primary: Colors.amber, // Background color
              shape: CircleBorder(), // Circular shape
              elevation: 3, // Elevation
            ),
            child: _isSubmitting
                ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
