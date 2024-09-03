import 'package:friendly_mobile_app/domain/fit_passport.dart';
 
class FitResponse{
  final List<FitPassport> passports;
  final int count;

  FitResponse({required this.passports, required this.count});

  factory FitResponse.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<FitPassport> passports = list.map((i) => FitPassport.fromJson(i)).toList();
    return FitResponse(
      passports: passports,
      count: json['count'] as int,
    );
  }
}