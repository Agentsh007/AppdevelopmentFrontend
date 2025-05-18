import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/screens/blood_bank/donor_register_screen.dart';
import 'package:my_app/presentation/widgets/custom_text_field.dart';
import 'dart:convert';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  _DonorProfileScreenState createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emergencyContactController = TextEditingController();
  final _preferredLocationController = TextEditingController();
  final _lastDonatedController = TextEditingController();
  bool _consent = false;
  bool _isLoading = false;
  Map<String, dynamic>? _profile;

 static final baseUrl = _getBaseUrl();
  static String _getBaseUrl() {
    if (Platform.isAndroid) {
      // Emulator
      return 'http://10.0.2.2:8000';
    } else {
      // iOS simulator or real device (both Android and iOS)
      return 'http://192.168.0.182:8000'; // Replace with your actual PC IP
    }
  }
  
  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _emergencyContactController.dispose();
    _preferredLocationController.dispose();
    _lastDonatedController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user?.token;
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }
      final response = await http.get(
        Uri.parse('$baseUrl/api/bloodbank/donor/profile/'),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _profile = jsonDecode(response.body);
          _emergencyContactController.text =
              _profile?['emergency_contact'] ?? '';
          _preferredLocationController.text =
              _profile?['preferred_location'] ?? '';
          _lastDonatedController.text = _profile?['last_donated'] ?? '';
          _consent = _profile?['consent'] ?? false;
        });
      } else if (response.statusCode == 404) {
        final error = jsonDecode(response.body);
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              
                  'No donor profile found. Please register as a donor.',
            ),
            // action: SnackBarAction(
            //   label: 'Register',
            //   onPressed: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //     builder: (context) => const DonorRegisterScreen(),
            //     //   ),
            //     // );
            //   },
            // ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user?.token;
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }
      final response = await http.patch(
        Uri.parse('$baseUrl/api/bloodbank/donor/profile/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'emergency_contact': _emergencyContactController.text,
          'preferred_location': _preferredLocationController.text,
          'last_donated':
              _lastDonatedController.text.isEmpty
                  ? null
                  : _lastDonatedController.text,
          'consent': _consent,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Profile updated successfully'),
          ),
        );
        await _fetchProfile(); // Refresh profile after update
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error['last_donated']?.join(', ') ?? 'Validation error',
            ),
          ),
        );
      } else if (response.statusCode == 404) {
        final error = jsonDecode(response.body);
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No donor profile found. Please register as a donor'),
            // action: SnackBarAction(
            //   label: 'Register',
            //   onPressed: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //     builder: (context) => const DonorRegisterScreen(),
            //     //   ),
            //     // );

            //   },
            // ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Profile'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (_profile == null)
                        const Center(
                          child: Text(
                            'No donor profile found. Please register as a donor.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else ...[
                        Card(
                          
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Details',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Name: ${_profile!['name'] ?? 'Not available'}',
                                ),
                                Text(
                                  'Blood Group: ${_profile!['blood_group'] ?? 'Not set'}',
                                ),
                                // Text(
                                //   'User ID: ${_profile!['user']?.toString() ?? 'Not available'}',
                                // ),
                                // Text(
                                //   'Detail URL: ${_profile!['detail_url'] ?? 'Not available'}',
                                // ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'Update Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emergencyContactController,
                        labelText: 'Emergency Contact',
                        obscureText: false,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Contact is required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _preferredLocationController,
                        labelText: 'Preferred Location',
                        obscureText: false,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Location is required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _lastDonatedController,
                        labelText: 'Last Donated (YYYY-MM-DD)',
                        obscureText: false,
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                            if (!datePattern.hasMatch(value)) {
                              return 'Enter valid date (YYYY-MM-DD)';
                            }
                            try {
                              final date = DateTime.parse(value);
                              final now =
                                  DateTime.now(); // May 18, 2025, 04:57 AM +06
                              if (date.isAfter(now)) {
                                return 'Last donated cannot be in the future';
                              }
                            } catch (e) {
                              return 'Invalid date format';
                            }
                          }
                          return null;
                        },
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _consent,
                            onChanged:
                                (value) => setState(() => _consent = value!),
                          ),
                          const Text('Consent to Donate'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: _updateProfile,
                            child: const Text('Update Profile'),
                          ),
                    ],
                  ),
                ),
      ),
    );
  }
}
