class AcademicUnitModel {
  final int id;
  final String name;
  final String shortName;
  final String unitType;
  final int universityId;

  AcademicUnitModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.unitType,
    required this.universityId,
  });

  factory AcademicUnitModel.fromJson(Map<String, dynamic> json) {
    return AcademicUnitModel(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'],
      unitType: json['unit_type'],
      universityId: json['university']['id'],
    );
  }
}