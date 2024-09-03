import 'dart:convert';
import 'package:friendly_mobile_app/domain/fit_response.dart';
import 'package:friendly_mobile_app/domain/fit_passport.dart';
import 'package:http/http.dart' as http;
import '../utility/app_url.dart';
import '../utility/shared_preference.dart';

class FitService {
  final String baseUrl;

  FitService({required this.baseUrl});

  Future<FitResponse> fetchPassports(String searchText,int currentPage, int limit) async {
    String uri = '${AppUrl.baseUrl}/fit?page=${currentPage - 1}&PageSize=$limit';

    var token = await UserPreferences().getToken();


    if (searchText.isNotEmpty) {
      uri += '&text=$searchText';
    }

    final response = await http.get(Uri.parse(uri),  headers: {
        'Authorization': 'Bearer $token',
      },);


    if (response.statusCode == 200) {

      Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> jsonList = responseBody['result'] as List<dynamic>;
      List<FitPassport> passports = jsonList.map((json) => FitPassport.fromJson(json as Map<String, dynamic>)).toList();
       int count = responseBody['count'] as int;

      return FitResponse(passports: passports, count: count);
    } else {
      throw Exception('Failed to load countries');
    }
  }
}
