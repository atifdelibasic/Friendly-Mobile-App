import 'country.dart';

class CountryResponse {
  final List<Country> countries;
  final int count;

  CountryResponse({required this.countries, required this.count});
}