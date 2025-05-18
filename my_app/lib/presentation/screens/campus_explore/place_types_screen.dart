import 'package:flutter/material.dart';
import 'package:my_app/presentation/services/api_service.dart';

class PlaceTypesScreen extends StatefulWidget {
  const PlaceTypesScreen({super.key});

  @override
  _PlaceTypesScreenState createState() => _PlaceTypesScreenState();
}

class _PlaceTypesScreenState extends State<PlaceTypesScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _placeTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaceTypes();
  }

  Future<void> _fetchPlaceTypes() async {
    setState(() => _isLoading = true);
    try {
      final placeTypes = await ApiService.fetchPlaceTypes();
      setState(() {
        _placeTypes = placeTypes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching place types: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Types'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _placeTypes.isEmpty
                ? const Center(
                    child: Text(
                      'No place types found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _placeTypes.length,
                    itemBuilder: (context, index) {
                      final type = _placeTypes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(type['name'] ?? 'Unnamed Type'),
                          subtitle: Text('ID: ${type['id']?.toString() ?? 'Not set'}'),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}