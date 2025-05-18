class TeacherDesignationModel {
  final int id;
  final String name;

  TeacherDesignationModel({required this.id, required this.name});

  factory TeacherDesignationModel.fromJson(Map<String, dynamic> json) {
    return TeacherDesignationModel(
      id: json['id'],
      name: json['name'],
    );
  }
}