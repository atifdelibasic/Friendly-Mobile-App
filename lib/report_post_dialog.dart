import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:friendly_mobile_app/utility/app_url.dart';
import 'package:friendly_mobile_app/utility/shared_preference.dart';
import 'package:http/http.dart' as http;
import 'domain/report_reason.dart';

class ReportPostDialog extends StatefulWidget {
  final int postId;

  ReportPostDialog({required this.postId});
  
  @override
  _ReportPostDialogState createState() => _ReportPostDialogState();
}

class _ReportPostDialogState extends State<ReportPostDialog> {
  List<ReportReason> _reasons = [];
  ReportReason? _selectedReason;
  TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchReportReasons();
  }

  void _fetchReportReasons() async {
    try {
      String token = await UserPreferences().getToken();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(Uri.parse("${AppUrl.baseUrl}/reportreason"), headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> reasonsJson = jsonDecode(response.body);
        List<ReportReason> reasons = reasonsJson.map((json) => ReportReason.fromJson(json)).toList();
        setState(() {
          _reasons = reasons;
        });
      } else {
        print('Failed to fetch report reasons: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch report reasons: $error');
    }
  }

  void _submitReport() async {
    if (_selectedReason != null) {
      setState(() {
        _isSubmitting = true;
      });

      String token = await UserPreferences().getToken();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Map<String, dynamic> body = {
        'postId': widget.postId,
        'reportReasonId': _selectedReason!.id,
        'additionalComment': _descriptionController.text,
      };

      var response = await http.post(
        Uri.parse("${AppUrl.baseUrl}/produce-message"),
        headers: headers,
        body: body.isNotEmpty ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200) {
        print("Report submitted successfully!");
      } else {
        print("Failed to submit report.");
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report submitted successfully!"), backgroundColor: Colors.green),
      );

      setState(() {
        _isSubmitting = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a reason for reporting.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Row(
        children: [
          Icon(Icons.report, color: Colors.red),
          SizedBox(width: 10),
          Text("Report Post"),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Reason for Report:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<ReportReason>(
              value: _selectedReason,
              items: _reasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Row(
                    children: [
                      Icon(Icons.bug_report, color: Colors.orange),
                      SizedBox(width: 10),
                      Text(reason.description),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Select Reason",
                prefixIcon: Icon(Icons.warning),
              ),
            ),
            if (_selectedReason == null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Please select a reason for reporting.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 16),
            Text("Description (optional):", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Description",
                prefixIcon: Icon(Icons.text_snippet),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitReport,
          icon: _isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.send),
          label: _isSubmitting ? Text("") : Text("Submit"),
        ),
      ],
    );
  }
}
