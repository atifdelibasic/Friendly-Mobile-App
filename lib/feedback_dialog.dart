import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/utility/app_url.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:http/http.dart' as http;

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  _FeedbackDialogState createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  final ValueNotifier<bool> _isSubmitEnabled = ValueNotifier(false);
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _feedbackController.addListener(_onFeedbackChanged);
  }

  void _onFeedbackChanged() {
    _isSubmitEnabled.value = _feedbackController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _feedbackController.removeListener(_onFeedbackChanged);
    _feedbackController.dispose();
    _isSubmitEnabled.dispose();
    super.dispose();
  }

  void _submitFeedback(BuildContext context) async {
  setState(() {
    _isSubmitting = true;
  });

  String token = await UserPreferences().getToken();
  var user = await UserPreferences().getUser();
  String url = "${AppUrl.baseUrl}/feedback";

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  Map<String, dynamic> body = {
    'userId': user.id,
    'text': _feedbackController.text, 
  };

  var response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body.isNotEmpty ? jsonEncode(body) : null,
  );

  if (response.statusCode == 200) {
    print("Feedback submitted successfully");
  } else {
    print("Error submitting feedback");
  }

  if (!mounted) return;

  setState(() {
    _isSubmitting = false;
  });

  Navigator.of(context).pop();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Thanks for giving feedback!")),
  );
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text("We Value Your Feedback"),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Your suggestions on what could be done better are appreciated.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _feedbackController,
              decoration: InputDecoration(
                hintText: "Enter your feedback here",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: EdgeInsets.all(15),
              ),
              maxLines: 3,
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
        ValueListenableBuilder<bool>(
          valueListenable: _isSubmitEnabled,
          builder: (context, isEnabled, child) {
            return TextButton(
              onPressed: _isSubmitting || !isEnabled ? null : () => _submitFeedback(context),
              child: _isSubmitting
                  ? CircularProgressIndicator()
                  : Text("Submit"),
            );
          },
        ),
      ],
    );
  }
}
