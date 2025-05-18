import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BloodGroupsScreen extends StatefulWidget {
  const BloodGroupsScreen({super.key});

  @override
  _BloodGroupsScreenState createState() => _BloodGroupsScreenState();
}

class _BloodGroupsScreenState extends State<BloodGroupsScreen> {
  List<String> _bloodGroups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBloodGroups();
  }

  Future<void> _fetchBloodGroups() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/bloodbank/bloodgroups/'));
      if (response.statusCode == 200) {
        setState(() {
          _bloodGroups = List<String>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching blood groups: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _bloodGroups.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_bloodGroups[index]),
                  onTap: () async {
                    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/bloodbank/bloodgroups/${_bloodGroups[index]}/'));
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Details: ${_bloodGroups[index]}')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Blood group not found')));
                    }
                  },
                );
              },
            ),
    );
  }
}