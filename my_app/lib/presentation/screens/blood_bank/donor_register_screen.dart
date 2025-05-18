import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/widgets/custom_text_field.dart';
import 'dart:convert';

class DonorRegisterScreen extends StatefulWidget {
  const DonorRegisterScreen({super.key});

  @override
  _DonorRegisterScreenState createState() => _DonorRegisterScreenState();
}

class _DonorRegisterScreenState extends State<DonorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emergencyContactController = TextEditingController();
  final _preferredLocationController = TextEditingController();
  final _lastDonatedController = TextEditingController();
  bool _consent = false;
  bool _isLoading = false;
  List<String> _bloodGroups = [];

  @override
  void initState() {
    super.initState();
    _fetchBloodGroups();
  }

  @override
  void dispose() {
    _emergencyContactController.dispose();
    _preferredLocationController.dispose();
    _lastDonatedController.dispose();
    super.dispose();
  }

  Future<void> _fetchBloodGroups() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/bloodbank/bloodgroups/'));
      if (response.statusCode == 200) {
        setState(() {
          _bloodGroups = List<String>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching blood groups: $e')));
    }
  }

  Future<void> _registerDonor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user?.token;
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/bloodbank/donor/register/'),
        headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'emergency_contact': _emergencyContactController.text,
          'preferred_location': _preferredLocationController.text,
          'last_donated': _lastDonatedController.text.isEmpty ? null : _lastDonatedController.text,
          'consent': _consent,
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donor registered successfully')));
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['message'] ?? 'Registration failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _emergencyContactController.clear();
    _preferredLocationController.clear();
    _lastDonatedController.clear();
    _consent = false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            CustomTextField(
              controller: _emergencyContactController,
              labelText: 'Emergency Contact',
              obscureText: false,
              validator: (value) => value!.isEmpty ? 'Contact is required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _preferredLocationController,
              labelText: 'Preferred Location',
              obscureText: false,
              validator: (value) => value!.isEmpty ? 'Location is required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _lastDonatedController,
              labelText: 'Last Donated (YYYY-MM-DD)',
              obscureText: false,
              validator: (value) {
                if (value!.isNotEmpty) {
                  final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!datePattern.hasMatch(value)) return 'Enter valid date (YYYY-MM-DD)';
                  final date = DateTime.parse(value);
                  final now = DateTime.now();
                  if (date.isAfter(now)) return 'Last donated cannot be in the future';
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
                  onChanged: (value) => setState(() => _consent = value!),
                ),
                const Text('Consent to Donate'),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _registerDonor,
                    child: const Text('Register as Donor'),
                  ),
          ],
        ),
      ),
    );
  }
}