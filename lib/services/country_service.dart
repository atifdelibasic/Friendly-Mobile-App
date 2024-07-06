import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/country.dart';
import '../domain/country_response.dart';
import '../utility/app_url.dart';
import '../utility/shared_preference.dart';

class CountryService {
  final String baseUrl;

  CountryService({required this.baseUrl});

  Future<CountryResponse> fetchCountries(String searchText,  int currentPage, int limit) async {
    String uri = '${AppUrl.baseUrl}/mobile/countries';

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
      List<Country> countries = jsonList.map((json) => Country.fromJson(json as Map<String, dynamic>)).toList();
       int count = responseBody['count'] as int;


      return CountryResponse(countries: countries, count: count);
    } else {
      throw Exception('Failed to load countries');
    }
  }

  Future<Country> fetchCountry(int id) async {
    final response = await http.get(Uri.parse('${AppUrl.baseUrl}/country/$id'));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      Country country = Country.fromJson(json);
      return country;
    } else {
      throw Exception('Failed to load country');
    }
  }
}
