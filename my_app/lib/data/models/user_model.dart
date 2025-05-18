class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String bloodGroup;
  final String? contactVisibility;
  final String role;
  final String adminLevel;
  final Map<String, dynamic>? university; // Allow null if not always present
  final Map<String, dynamic>? academicUnit; // Allow null if not always present
  final String? teacherDesignation;
  final String? designation;
  final String? workplace;
  final String token;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    this.contactVisibility,
    required this.role,
    required this.adminLevel,
    this.university,
    this.academicUnit,
    this.teacherDesignation,
    this.designation,
    this.workplace,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0, // Default to 0 if null, adjust as needed
      name:
          json['name'] as String? ?? 'Unknown', // Default to 'Unknown' if null
      email: json['email'] as String? ?? '', // Default to empty string if null
      phone: json['phone'] as String? ?? '', // Default to empty string if null
      bloodGroup:
          json['blood_group'] as String? ??
          '', // Default to empty string if null
      contactVisibility: json['contact_visibility'] as String?,
      role:
          json['role'] as String? ?? 'unknown', // Default to 'unknown' if null
      adminLevel:
          json['admin_level'] as String? ?? 'none', // Default to 'none' if null
      university: json['university'] as Map<String, dynamic>?,
      academicUnit: json['academic_unit'] as Map<String, dynamic>?,
      teacherDesignation: json['teacher_designation'] as String?,
      designation: json['designation'] as String?,
      workplace: json['workplace'] as String?,
      token: json['token'] ?? '',
    );
  }
   @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, university: $university)';
  }
}
