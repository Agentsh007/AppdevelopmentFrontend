import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:practice_1/colors/colors.dart';
import 'package:practice_1/models/user.dart';
import 'package:practice_1/screens/login_screen.dart';
import 'package:practice_1/services/api_service.dart';
import 'package:practice_1/services/auth_service.dart';
import 'package:practice_1/services/session_service.dart';

class ProfileController extends GetxController {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final phoneNo = TextEditingController();
  final password = TextEditingController();
  var obscurePassword = true.obs;
  File? selectedImage;

  @override
  void onClose() {
    fullName.dispose();
    email.dispose();
    phoneNo.dispose();
    password.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
}

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final controller = Get.put(ProfileController());
  final SessionService _sessionService = SessionService();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() => _isLoading = true);
    try {
      final email = await _sessionService.getSessionEmail();
      final token = await _sessionService.getSessionToken();
      if (email != null && token != null) {
        final user = await _apiService.getUserDetails(email, token);
        if (user != null) {
          controller.fullName.text = user.username;
          controller.email.text = user.email;
          controller.phoneNo.text = user.phoneNumber;
          controller.password.text = user.password;
          setState(() {
            _user = user;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user details: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        controller.selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (controller.fullName.text.isEmpty ||
        controller.email.text.isEmpty ||
        controller.phoneNo.text.isEmpty ||
        controller.password.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = await _sessionService.getSessionToken();
      final email = await _sessionService.getSessionEmail();
      if (token != null && email != null) {
        String? profilePicture = _user?.profilePicture;
        if (controller.selectedImage != null) {
          profilePicture = await _apiService.updateProfilePicture(
              controller.selectedImage!, token, email);
        }
        final updatedUser = User(
          username: controller.fullName.text,
          email: controller.email.text,
          password: controller.password.text,
          phoneNumber: controller.phoneNo.text,
          university: _user?.university ?? '',
          department: _user?.department ?? '',
          bloodGroup: _user?.bloodGroup ?? '',
          profilePicture: profilePicture ?? '',
        );
        // Note: Using register as a placeholder; replace with proper update API if available
        await _authService.register(updatedUser);
        Get.snackbar('Success', 'Profile updated successfully',
            icon: const Icon(Icons.check_circle),
            backgroundColor: Colors.green,
            colorText: Colors.white);
        Navigator.pop(context);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final email = await _sessionService.getSessionEmail();
      final token = await _sessionService.getSessionToken();
      if (email != null && token != null) {
        await _apiService.deleteAccount(email, token);
        await _sessionService.clearSession();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
        Get.snackbar('Success', 'Account deleted successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryText(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.buttonAccent(context),
                              width: 3,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: controller.selectedImage != null
                                ? Image.file(
                                    controller.selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : _user?.profilePicture.isNotEmpty == true
                                    ? Image.network(
                                        '${ApiService.baseUrl}${_user!.profilePicture}',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          LineAwesomeIcons.user,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : const Icon(
                                        LineAwesomeIcons.user,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.buttonAccent(context),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller.fullName,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      fillColor: AppColors.background(context),
                      filled: true,
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      fillColor: AppColors.background(context),
                      filled: true,
                    ),
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.phoneNo,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      fillColor: AppColors.background(context),
                      filled: true,
                    ),
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => TextField(
                      controller: controller.password,
                      obscureText: controller.obscurePassword.value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        fillColor: AppColors.background(context),
                        filled: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.secondaryText(context),
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonAccent(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Update Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Delete Account',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                              'Are you sure you want to delete your account? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _deleteAccount();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Delete',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ),
                          ],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Delete Account',
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}