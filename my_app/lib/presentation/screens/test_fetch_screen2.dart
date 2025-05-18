import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/services/api_service.dart';
import 'package:my_app/data/models/lost_and_found_item.dart';
import 'dart:developer' as developer;

class TestFetchScreen2 extends StatefulWidget {
  const TestFetchScreen2({Key? key}) : super(key: key);

  @override
  _TestFetchScreenState createState() => _TestFetchScreenState();
}

class _TestFetchScreenState extends State<TestFetchScreen2> {
  List<LostAndFoundItem> _lostItems = [];
  List<LostAndFoundItem> _foundItems = [];
  String? _lostItemsError;
  String? _foundItemsError;

  @override
  void initState() {
    super.initState();
    // Fetch data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.fetchUniversities();
      authProvider.fetchAcademicUnits(1); // Use a sample university ID (e.g., 1)
      authProvider.fetchTeacherDesignations();
      _fetchLostAndFoundItems();
    });
  }

  Future<void> _fetchLostAndFoundItems() async {
    try {
      developer.log('Fetching lost items...');
      final lostItems = await ApiService.fetchLostAndFoundItems('lost');
      setState(() {
        _lostItems = lostItems;
      });
      developer.log('Lost items fetched: ${_lostItems.length} items');
    } catch (e) {
      setState(() {
        _lostItemsError = 'Failed to load lost items: $e';
      });
      developer.log('Lost items fetch error: $_lostItemsError');
    }

    try {
      developer.log('Fetching found items...');
      final foundItems = await ApiService.fetchLostAndFoundItems('found');
      setState(() {
        _foundItems = foundItems;
      });
      developer.log('Found items fetched: ${_foundItems.length} items');
    } catch (e) {
      setState(() {
        _foundItemsError = 'Failed to load found items: $e';
      });
      developer.log('Found items fetch error: $_foundItemsError');
    }
  }

  void _refreshData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchUniversities();
    authProvider.fetchAcademicUnits(1);
    authProvider.fetchTeacherDesignations();
    _fetchLostAndFoundItems();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Fetch Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: authProvider.isLoading && _lostItems.isEmpty && _foundItems.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Universities Section
                    const Text(
                      'Universities:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (authProvider.universities.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: authProvider.universities.length,
                        itemBuilder: (context, index) {
                          final university = authProvider.universities[index];
                          return ListTile(
                            title: Text(university.name),
                            subtitle: Text('ID: ${university.id}'),
                          );
                        },
                      )
                    else if (authProvider.errorMessage != null)
                      Text(
                        'Error: ${authProvider.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      const Text('No universities fetched yet.'),

                    const SizedBox(height: 16),
                    // Academic Units Section
                    const Text(
                      'Academic Units:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (authProvider.academicUnits.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: authProvider.academicUnits.length,
                        itemBuilder: (context, index) {
                          final unit = authProvider.academicUnits[index];
                          return ListTile(
                            title: Text(unit.name),
                            subtitle: Text('ID: ${unit.id}, University ID: ${unit.universityId}'),
                          );
                        },
                      )
                    else if (authProvider.errorMessage != null)
                      Text(
                        'Error: ${authProvider.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      const Text('No academic units fetched yet.'),

                    const SizedBox(height: 16),
                    // Teacher Designations Section
                    const Text(
                      'Teacher Designations:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (authProvider.teacherDesignations.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: authProvider.teacherDesignations.length,
                        itemBuilder: (context, index) {
                          final designation = authProvider.teacherDesignations[index];
                          return ListTile(
                            title: Text(designation.name),
                            subtitle: Text('ID: ${designation.id}'),
                          );
                        },
                      )
                    else if (authProvider.errorMessage != null)
                      Text(
                        'Error: ${authProvider.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      const Text('No teacher designations fetched yet.'),

                    const SizedBox(height: 16),
                    // Lost Items Section
                    const Text(
                      'Lost Items:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_lostItems.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _lostItems.length,
                        itemBuilder: (context, index) {
                          final item = _lostItems[index];
                          return ListTile(
                            title: Text(item.title),
                            subtitle: Text('ID: ${item.id}, Category: ${item.title}'), // Fixed to use title instead of category
                          );
                        },
                      )
                    else if (_lostItemsError != null)
                      Text(
                        'Error: $_lostItemsError',
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      const Text('No lost items fetched yet.'),

                    const SizedBox(height: 16),
                    // Found Items Section
                    const Text(
                      'Found Items:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_foundItems.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _foundItems.length,
                        itemBuilder: (context, index) {
                          final item = _foundItems[index];
                          return ListTile(
                            title: Text(item.title),
                            subtitle: Text('ID: ${item.id}, Category: ${item.title}'), // Fixed to use title instead of category
                          );
                        },
                      )
                    else if (_foundItemsError != null)
                      Text(
                        'Error: $_foundItemsError',
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      const Text('No found items fetched yet.'),
                  ],
                ),
              ),
      ),
    );
  }
}