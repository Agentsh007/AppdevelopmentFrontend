import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/services/api_service.dart';
import 'package:my_app/presentation/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _contactVisibilityController = TextEditingController();
  final _roleController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final user = authProvider.user!;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _bloodGroupController.text = user.bloodGroup;
      _contactVisibilityController.text = user.contactVisibility ?? 'both';
      _roleController.text = user.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bloodGroupController.dispose();
    _contactVisibilityController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'blood_group': _bloodGroupController.text,
        'contact_visibility': _contactVisibilityController.text,
        'role': _roleController.text,
      };
      await ApiService.updateProfile(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context); // Return to profile screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Name',
                obscureText: false,
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                obscureText: false,
                validator: (value) {
                  if (value!.isEmpty) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Invalid email format';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone',
                obscureText: false,
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Phone is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bloodGroupController,
                labelText: 'Blood Group',
                obscureText: false,
                validator: (value) => value!.isEmpty ? 'Blood group is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contactVisibilityController,
                labelText: 'Contact Visibility (both/email/private)',
                obscureText: false,
                validator: (value) {
                  if (value!.isEmpty) return 'Contact visibility is required';
                  if (!['both', 'email'].contains(value.toLowerCase())) return 'Invalid visibility option';
                  return null;
                },
              ),
               
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}