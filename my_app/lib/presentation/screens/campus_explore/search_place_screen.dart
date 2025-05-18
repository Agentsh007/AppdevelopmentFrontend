import 'package:flutter/material.dart';
import 'package:my_app/presentation/services/api_service.dart';
import 'package:my_app/presentation/screens/campus_explore/place_detail_screen.dart';
import 'package:my_app/presentation/widgets/custom_text_field.dart';

class SearchPlaceScreen extends StatefulWidget {
  const SearchPlaceScreen({super.key});

  @override
  _SearchPlaceScreenState createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  final _universityController = TextEditingController();
  final _placeTypeController = TextEditingController();
  final _nameController = TextEditingController();
  final _relativeLocationController = TextEditingController();
  final _academicUnitController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _places = [];

  Future<void> _searchPlaces() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, dynamic>{};
      if (_universityController.text.isNotEmpty) queryParams['university'] = _universityController.text;
      if (_placeTypeController.text.isNotEmpty) queryParams['place_type'] = _placeTypeController.text;
      if (_nameController.text.isNotEmpty) queryParams['name'] = _nameController.text;
      if (_relativeLocationController.text.isNotEmpty) queryParams['relative_location'] = _relativeLocationController.text;
      if (_academicUnitController.text.isNotEmpty) queryParams['academic_unit'] = _academicUnitController.text;

      final places = await ApiService.searchPlaces(queryParams);
      setState(() {
        _places = places;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching places: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Places'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _universityController,
              labelText: 'University',
              obscureText: false,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _placeTypeController,
              labelText: 'Place Type',
              obscureText: false,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              labelText: 'Name',
              obscureText: false,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _relativeLocationController,
              labelText: 'Relative Location',
              obscureText: false,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _academicUnitController,
              labelText: 'Academic Unit',
              obscureText: false,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchPlaces,
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _places.isEmpty
                        ? const Center(
                            child: Text(
                              'No places found.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _places.length,
                            itemBuilder: (context, index) {
                              final place = _places[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(place['name'] ?? 'Unnamed Place'),
                                  subtitle: Text(
                                    'Type: ${place['place_type'] ?? 'Not set'} | Location: ${place['relative_location'] ?? 'Not set'}',
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlaceDetailScreen(place: place),
                                      ),
                                    );
                                  },
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