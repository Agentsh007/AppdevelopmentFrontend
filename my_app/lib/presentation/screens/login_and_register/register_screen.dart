import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/data/models/university_model.dart';
import 'package:my_app/data/models/academic_unit_model.dart';
import 'package:my_app/data/models/teacher_designation_model.dart'; // Assume this model exists
import 'package:my_app/presentation/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  String _role = 'student';
  int? _selectedUniversityId;
  int? _selectedAcademicUnitId;
  int? _selectedTeacherDesignationId; // Changed to store ID

  @override
  void initState() {
    super.initState();
    // Fetch universities and teacher designations when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.fetchUniversities();
      authProvider.fetchTeacherDesignations(); // Assume this method exists
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^\+\d{10,15}$').hasMatch(value)) {
                      return 'Please enter a valid phone number (e.g., +1234567890)';
                    }
                    return null;
                  },
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _bloodGroupController,
                  labelText: 'Blood Group',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your blood group';
                    }
                    if (!['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].contains(value)) {
                      return 'Please enter a valid blood group';
                    }
                    return null;
                  },
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedUniversityId,
                  decoration: const InputDecoration(
                    labelText: 'University',
                    border: OutlineInputBorder(),
                  ),
                  items: authProvider.universities
                      .map((university) => DropdownMenuItem(
                            value: university.id,
                            child: Text(university.name),
                          ))
                      .toList(),
                  onChanged: (value) async {
                    setState(() {
                      _selectedUniversityId = value;
                      _selectedAcademicUnitId = null; // Reset academic unit
                    });
                    if (value != null) {
                      await authProvider.fetchAcademicUnits(value);
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a university';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedAcademicUnitId,
                  decoration: const InputDecoration(
                    labelText: 'Academic Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: _selectedUniversityId == null
                      ? []
                      : authProvider.academicUnits
                          .where((unit) => unit.universityId == _selectedUniversityId)
                          .map((unit) => DropdownMenuItem(
                                value: unit.id,
                                child: Text(unit.shortName),
                              ))
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAcademicUnitId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null && _selectedUniversityId != null) {
                      return 'Please select an academic unit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: ['student', 'teacher', 'officer', 'staff']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _role = value!;
                      _selectedTeacherDesignationId = null; // Reset teacher designation
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Conditionally show teacher_designation dropdown for "teacher" role
                if (_role == 'teacher')
                  DropdownButtonFormField<int>(
                    value: _selectedTeacherDesignationId,
                    decoration: const InputDecoration(
                      labelText: 'Teacher Designation',
                      border: OutlineInputBorder(),
                    ),
                    items: authProvider.teacherDesignations
                        .map((designation) => DropdownMenuItem(
                              value: designation.id,
                              child: Text(designation.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTeacherDesignationId = value;
                      });
                    },
                    validator: (value) {
                      if (_role == 'teacher' && value == null) {
                        return 'Please select a teacher designation';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 20),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await authProvider.register(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
                              phone: _phoneController.text,
                              bloodGroup: _bloodGroupController.text,
                              role: _role,
                              university: _selectedUniversityId!,
                              academicUnit: _selectedAcademicUnitId!,
                              teacherDesignation: _role == 'teacher' ? _selectedTeacherDesignationId : null,
                            );
                            if (authProvider.errorMessage == null) {
                              Navigator.pushNamed(
                                context,
                                '/verify-email',
                                arguments: _emailController.text,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(authProvider.errorMessage!)),
                              );
                            }
                          }
                        },
                        child: const Text('Register'),
                      ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Already have an account? Login'),
                ),
                if (authProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}