class Country {
  int id;
  String name;
  String dateCreated;
   String? deletedAt;  

  Country({
    required this.name,
    required this.id,
    required this.dateCreated,
    this.deletedAt,  

  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      id: json['id'] as int,
      dateCreated: json['dateCreated'] as String,
      deletedAt: json['deletedAt'] as String?, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateCreated': dateCreated,
      'deletedAt': deletedAt,
      'id': id
    };
  }
}
