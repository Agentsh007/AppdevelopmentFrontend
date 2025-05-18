import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/presentation/widgets/custom_text_field.dart';
import 'dart:convert';

class DonorListScreen extends StatefulWidget {
  const DonorListScreen({super.key});

  @override
  _DonorListScreenState createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  final _bloodGroupController = TextEditingController();
  bool _isLoading = false;
  List<String> _bloodGroups = [];
  List<Map<String, dynamic>> _donors = [];
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
    _fetchBloodGroups();
    _fetchDonors();
  }

  @override
  void dispose() {
    _bloodGroupController.dispose();
    super.dispose();
  }

  Future<void> _fetchBloodGroups() async {
    try {
      final response = await http.get(
        Uri.parse(' $baseUrl/api/bloodbank/bloodgroups/'),
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

  Future<void> _fetchDonors({String? bloodGroup}) async {
    setState(() => _isLoading = true);
    try {
      String url = '$baseUrl/api/bloodbank/donors/';
      if (bloodGroup != null && bloodGroup.isNotEmpty && bloodGroup != 'All') {
        url += '?blood_group=$bloodGroup';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _donors = List<Map<String, dynamic>>.from(data['results']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch donors')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching donors: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDonorDetail(int index) {
    final donor = _donors[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Donor Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${donor['name'] ?? 'Unknown'}'),
              Text('Blood Group: ${donor['blood_group'] ?? 'Not set'}'),
              Text('Emergency Contact: ${donor['emergency_contact'] ?? 'Not available'}'),
              Text('Preferred Location: ${donor['preferred_location'] ?? 'Not set'}'),
              Text('Last Donated: ${donor['last_donated'] ?? 'Not set'}'),
              Text('Consent: ${donor['consent'] ? 'Yes' : 'No'}'),
              // Text('User ID: ${donor['user']?.toString() ?? 'Not available'}'),
              // Text('Detail URL: ${donor['detail_url'] ?? 'Not available'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor List'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _bloodGroupController.text.isEmpty
                        ? null
                        : _bloodGroupController.text,
                    hint: const Text('Filter by BG'),
                    items: ['All', ..._bloodGroups]
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
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _fetchDonors(
                      bloodGroup: _bloodGroupController.text == 'All'
                          ? null
                          : _bloodGroupController.text,
                    ),
                    child: const Text('Filter'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _donors.isEmpty
                        ? const Center(
                            child: Text(
                              'No donors found.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _donors.length,
                            itemBuilder: (context, index) {
                              final donor = _donors[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(donor['name'] ?? 'Unknown'),
                                  subtitle: Text(
                                    'Blood Group: ${donor['blood_group'] ?? 'Not set'} | Location: ${donor['preferred_location'] ?? 'Not set'}',
                                  ),
                                  onTap: () => _showDonorDetail(index),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}