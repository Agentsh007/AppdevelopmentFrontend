import 'package:flutter/material.dart';
import 'package:my_app/presentation/services/api_service.dart';
import 'package:my_app/presentation/screens/campus_explore/place_detail_screen.dart';

class PlaceListScreen extends StatefulWidget {
  const PlaceListScreen({super.key});

  @override
  _PlaceListScreenState createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _places = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    setState(() => _isLoading = true);
    try {
      final places = await ApiService.fetchPlaces();
      setState(() {
        _places = places;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching places: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _places.isEmpty
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
    );
  }
}