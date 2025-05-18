import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'dart:convert';

class CreateBloodRequestScreen extends StatefulWidget {
  const CreateBloodRequestScreen({super.key});

  @override
  _CreateBloodRequestScreenState createState() => _CreateBloodRequestScreenState();
}

class _CreateBloodRequestScreenState extends State<CreateBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _universityController = TextEditingController();
  final _requestDateController = TextEditingController();
  final _locationController = TextEditingController();
  bool _urgent = false;
  bool _isLoading = false;
  List<String> _bloodGroups = [];
  List<Map<String, dynamic>> _universities = [];

  @override
  void initState() {
    super.initState();
    _fetchBloodGroups();
    _fetchUniversities();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _bloodGroupController.dispose();
    _universityController.dispose();
    _requestDateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchBloodGroups() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/bloodbank/bloodgroups/'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _bloodGroups = List<String>.from(jsonDecode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch blood groups')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching blood groups: $e')),
      );
    }
  }

  Future<void> _fetchUniversities() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/universities/'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _universities = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch universities')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching universities: $e')),
      );
    }
  }

  Future<void> _createRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user?.token;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/bloodbank/requests/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'blood_group': _bloodGroupController.text,
          'university': int.parse(_universityController.text),
          'request_date': _requestDateController.text,
          'urgent': _urgent,
          'location': _locationController.text,
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blood request created successfully')),
        );
        Navigator.pop(context); // Return to the requests list
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['blood_group']?.join(', ') ?? 'Validation error')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create blood request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating blood request: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Blood Request'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _bloodGroupController.text.isEmpty ? null : _bloodGroupController.text,
                hint: const Text('Select Blood Group'),
                items: _bloodGroups
                    .map((group) => DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _bloodGroupController.text = value ?? '';
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Blood Group',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Blood group is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _universityController.text.isEmpty ? null : _universityController.text,
                hint: const Text('Select University'),
                items: _universities
                    .map((uni) => DropdownMenuItem(
                          value: uni['id'].toString(),
                          child: Text(uni['name']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _universityController.text = value ?? '';
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'University',
                ),
                validator: (value) => value == null || value.isEmpty ? 'University is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _requestDateController,
                decoration: const InputDecoration(labelText: 'Request Date (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value!.isEmpty) return 'Request date is required';
                  final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!datePattern.hasMatch(value)) {
                    return 'Enter valid date (YYYY-MM-DD)';
                  }
                  try {
                    final date = DateTime.parse(value);
                    final now = DateTime.now();
                    if (date.isBefore(now)) {
                      return 'Request date cannot be in the past';
                    }
                  } catch (e) {
                    return 'Invalid date format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _urgent,
                    onChanged: (value) => setState(() => _urgent = value!),
                  ),
                  const Text('Urgent Request'),
                ],
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createRequest,
                      child: const Text('Create Request'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}