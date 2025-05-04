import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practice_1/colors/colors.dart';
import 'package:practice_1/main.dart';
import 'package:practice_1/models/user.dart';
import 'package:practice_1/services/api_service.dart';
import 'package:practice_1/services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionService _sessionService = SessionService();
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadTheme();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final email = await _sessionService.getSessionEmail();
      final token = await _sessionService.getSessionToken();
      if (email != null && token != null) {
        final user = await _apiService.getUserDetails(email, token);
        setState(() {
          _user = user;
        });
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _updateProfilePicture();
    }
  }

  Future<void> _updateProfilePicture() async {
    if (_profileImage == null) return;
    setState(() => _isLoading = true);
    try {
      final token = await _sessionService.getSessionToken();
      final email = await _sessionService.getSessionEmail();
      if (token != null && email != null) {
        final imagePath = await _apiService.updateProfilePicture(
          _profileImage!,
          token,
          email,
        );
        setState(() {
          _user = _user?.copyWith(profilePicture: imagePath);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _sessionService.clearSession();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground(context),
        title: Text('Delete Account', style: GoogleFonts.poppins(color: AppColors.primaryText(context))),
        content: Text(
          'Are you sure you want to delete your account? This action is irreversible.',
          style: GoogleFonts.poppins(color: AppColors.secondaryText(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.secondaryText(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final token = await _sessionService.getSessionToken();
        final email = await _sessionService.getSessionEmail();
        if (token != null && email != null) {
          await _apiService.deleteAccount(email, token);
          await _sessionService.clearSession();
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryText(context)))
          : _user == null
              ? Center(
                  child: Text(
                    'Unable to load profile',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Picture
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : _user!.profilePicture.isNotEmpty
                                    ? NetworkImage('${ApiService.baseUrl}${_user!.profilePicture}')
                                    : null,
                            child: _user!.profilePicture.isEmpty && _profileImage == null
                                ? Icon(Icons.person, size: 50, color: AppColors.secondaryText(context))
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Username and Subtitle
                        Text(
                          _user!.username,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Campus Connect User',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Stats Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(context, '14', 'Following'),
                            _buildStatCard(context, 'BS', 'Followers'),
                            _buildStatCard(context, '20', 'Posts'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Menu Items
                        _buildMenuItem(context, 'Personal Info', Icons.person, () {
                          _showPersonalInfoDialog(context);
                        }),
                        _buildMenuItem(context, 'Dark Mode', Icons.brightness_6, () {}, trailing: Switch(
                          value: _isDarkMode,
                          onChanged: _toggleTheme,
                          activeColor: AppColors.accent(context),
                        )),
                        _buildMenuItem(context, 'Logout', Icons.logout, _logout, textColor: Colors.redAccent),
                        _buildMenuItem(context, 'Delete Account', Icons.delete_forever, _deleteAccount, textColor: Colors.redAccent),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent(context),
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText(context),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.secondaryText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, VoidCallback onTap, {Color? textColor, Widget? trailing}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent(context).withOpacity(0.3),
          ),
          child: Icon(icon, color: AppColors.primaryText(context)),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? AppColors.primaryText(context),
          ),
        ),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.secondaryText(context)),
        onTap: onTap,
      ),
    );
  }

  void _showPersonalInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground(context),
        title: Text('Personal Information', style: GoogleFonts.poppins(color: AppColors.primaryText(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Email', _user!.email, context),
            _buildInfoRow('University', _user!.university, context),
            _buildInfoRow('Department', _user!.department, context),
            _buildInfoRow('Blood Group', _user!.bloodGroup, context),
            _buildInfoRow('Phone', _user!.phoneNumber, context),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: AppColors.primaryText(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.secondaryText(context),
            ),
          ),
          Text(
            value.isEmpty ? 'Not provided' : value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText(context),
            ),
          ),
        ],
      ),
    );
  }
}

extension on User {
  User copyWith({String? profilePicture}) {
    return User(
      username: username,
      email: email,
      password: password,
      university: university,
      department: department,
      bloodGroup: bloodGroup,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}