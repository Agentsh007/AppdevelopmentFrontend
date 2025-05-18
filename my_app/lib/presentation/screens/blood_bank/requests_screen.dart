import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/presentation/screens/blood_bank/create_blood_request_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'dart:convert';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user?.token;
      print('Fetching requests with token: $token');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/bloodbank/requests/'),
        headers: token != null ? {'Authorization': 'Token $token'} : {},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Handle both paginated response and single request object
          if (data is Map<String, dynamic> && data.containsKey('results')) {
            _requests = List<Map<String, dynamic>>.from(data['results']);
          } else if (data is Map<String, dynamic>) {
            _requests = [data]; // Treat single object as a list with one item
          } else {
            throw Exception('Unexpected response format');
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch blood requests: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error fetching requests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching blood requests: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRequestDetail(int index) {
    final request = _requests[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blood Request Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${request['title'] ?? 'Not set'}'),
              Text('Description: ${request['description'] ?? 'Not set'}'),
              Text('Blood Group: ${request['blood_group'] is Map ? request['blood_group']['name'] ?? 'Not set' : request['blood_group']?.toString() ?? 'Not set'}'),
              Text('User: ${request['user'] != null ? request['user']['name'] ?? 'Unknown' : 'Unknown'}'),
              Text('University: ${request['university'] is Map ? request['university']['name'] ?? 'Not set' : request['university']?.toString() ?? 'Not set'}'),
              Text('Request Date: ${request['request_date'] ?? 'Not set'}'),
              Text('Urgent: ${request['urgent'] == true ? 'Yes' : 'No'}'),
              Text('Location: ${request['location'] ?? 'Not set'}'),
              Text('Status: ${request['status'] ?? 'Not set'}'),
              // Text('Created At: ${request['created_at'] ?? 'Not set'}'),
              // Text('Updated At: ${request['updated_at'] ?? 'Not set'}'),
              Text('Resolved By: ${request['resolved_by'] != null ? request['resolved_by']['name'] ?? 'Not resolved' : 'Not resolved'}'),
              // Text('Media: ${request['media']?.isEmpty ?? true ? 'None' : request['media'].toString()}'),
              Text('Registered Donors: ${request['registered_donors']?.isEmpty ?? true ? 'None' : request['registered_donors'].toString()}'),
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
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, '/login');
      });
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateBloodRequestScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error navigating to create request: $e')),
                );
              }
            },
            child: const Text('Create Blood Request'),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: _requests.isEmpty
                      ? const Center(
                          child: Text(
                            'No blood requests found.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            final request = _requests[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(request['title'] ?? 'Untitled Request'),
                                subtitle: Text(
                                  'Blood Group: ${request['blood_group'] is Map ? request['blood_group']['name'] ?? 'Not set' : request['blood_group']?.toString() ?? 'Not set'} | Location: ${request['location'] ?? 'Not set'}',
                                ),
                                trailing: request['urgent'] == true
                                    ? const Icon(Icons.warning, color: Colors.red)
                                    : null,
                                onTap: () => _showRequestDetail(index),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}