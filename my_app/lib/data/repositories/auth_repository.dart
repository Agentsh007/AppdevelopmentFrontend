import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/core/constants.dart';
import 'package:my_app/data/models/university_model.dart';
import 'package:my_app/data/models/academic_unit_model.dart';
import 'package:my_app/data/models/teacher_designation_model.dart';
import 'package:my_app/data/models/user_model.dart';
import 'dart:developer' as developer;

class AuthRepository {
  final storage = const FlutterSecureStorage();

  Future<List<TeacherDesignationModel>> fetchTeacherDesignations() async {
    developer.log('Fetching teacher designations from: ${Constants.baseUrl}/accounts/teacher-designations/');
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/universities/teacher-designations/'),
      headers: {'Content-Type': 'application/json'},
    );

    developer.log('Teacher designations response status: ${response.statusCode}');
    developer.log('Teacher designations response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TeacherDesignationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch teacher designations. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String bloodGroup,
    required String role,
    required int university,
    required int academicUnit,
    int? teacherDesignation,
  }) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/accounts/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'phone': phone,
        'blood_group': bloodGroup,
        'role': role,
        'university': university,
        'academic_unit': academicUnit,
        'teacher_designation': teacherDesignation,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<void> verifyEmail(String email, String code) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/accounts/verify-email/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/accounts/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('Login response status: ${response.statusCode}');
    print('Login response body: ${response.body}');

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        print('Storing token: ${data['token']}');
        await storage.write(key: 'auth_token', value: data['token']);
        data['user']['token'] = data['token'];
      } else {
        print('Token not found in response or login failed');
      }
      return data;
    } catch (e) {
      print('Error parsing login response: $e');
      throw Exception('Failed to parse login response: $e');
    }
  }

  Future<void> logout() async {
    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      await http.post(
        Uri.parse('${Constants.baseUrl}/accounts/logout/'),
        headers: {'Authorization': 'Token $token'},
      );
      await storage.delete(key: 'auth_token');
    }
  }

  Future<List<UniversityModel>> fetchUniversities() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/universities/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UniversityModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch universities. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<List<AcademicUnitModel>> fetchAcademicUnits(int universityId) async {
    print('Fetching academic units for universityId: $universityId');
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/universities/departments-institutes/?university_id=$universityId'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> departments = data['departments'] ?? [];
      final List<dynamic> institutes = data['institutes'] ?? [];
      return [...departments, ...institutes]
          .map((json) => AcademicUnitModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch academic units for university $universityId. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}