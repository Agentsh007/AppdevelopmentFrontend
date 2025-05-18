import 'package:flutter/material.dart';
import 'package:my_app/data/repositories/auth_repository.dart';
import 'package:my_app/data/models/university_model.dart';
import 'package:my_app/data/models/academic_unit_model.dart';
import 'package:my_app/data/models/teacher_designation_model.dart';
import 'package:my_app/data/models/user_model.dart';
import 'dart:developer' as developer;

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;
  List<UniversityModel> _universities = [];
  List<AcademicUnitModel> _academicUnits = [];
  List<TeacherDesignationModel> _teacherDesignations = [];

  AuthProvider(this._authRepository);

  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<UniversityModel> get universities => _universities;
  List<AcademicUnitModel> get academicUnits => _academicUnits;
  List<TeacherDesignationModel> get teacherDesignations => _teacherDesignations;
  bool get isLoggedIn => _user != null;

  Future<void> fetchUniversities() async {
    _isLoading = true;
    notifyListeners();
    developer.log('Fetching universities...');

    try {
      _universities = await _authRepository.fetchUniversities();
      developer.log('Universities fetched: ${_universities.length} items');
    } catch (e) {
      _errorMessage = 'Failed to load universities: $e';
      developer.log('University fetch error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAcademicUnits(int universityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    developer.log('Fetching academic units for universityId: $universityId');

    try {
      _academicUnits = await _authRepository.fetchAcademicUnits(universityId);
      developer.log('Academic units fetched: ${_academicUnits.length} items');
    } catch (e) {
      _errorMessage = 'Failed to load academic units: $e';
      _academicUnits = [];
      developer.log('Academic unit fetch error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeacherDesignations() async {
    _isLoading = true;
    notifyListeners();
    developer.log('Fetching teacher designations...');

    try {
      _teacherDesignations = await _authRepository.fetchTeacherDesignations();
      developer.log('Teacher designations fetched: ${_teacherDesignations.length} items');
    } catch (e) {
      _errorMessage = 'Failed to load teacher designations: $e';
      _teacherDesignations = [];
      developer.log('Teacher designation fetch error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phone: phone,
        bloodGroup: bloodGroup,
        role: role,
        university: university,
        academicUnit: academicUnit,
        teacherDesignation: teacherDesignation,
      );

      if (response['message'] != 'User registered, please verify your email.') {
        _errorMessage = response['message'].toString();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyEmail(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.verifyEmail(email, code);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(email, password);

      if (response['token'] != null && response['user'] != null) {
        _user = UserModel.fromJson(response['user']);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login failed: Token or user data not found';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    notifyListeners();
  }
}