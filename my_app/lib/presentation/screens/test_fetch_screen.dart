import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';

class TestFetchScreen extends StatefulWidget {
  const TestFetchScreen({Key? key}) : super(key: key);

  @override
  _TestFetchScreenState createState() => _TestFetchScreenState();
}

class _TestFetchScreenState extends State<TestFetchScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.fetchUniversities();
      authProvider.fetchAcademicUnits(1); // Use a sample university ID (e.g., 1)
      authProvider.fetchTeacherDesignations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Fetch Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: authProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
      ),
    );
  }
}