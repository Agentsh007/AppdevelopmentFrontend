class UniversityModel {
  final int id;
  final String name;
  final String shortName;

  UniversityModel({
    required this.id,
    required this.name,
    required this.shortName,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'],
    );
  }
}