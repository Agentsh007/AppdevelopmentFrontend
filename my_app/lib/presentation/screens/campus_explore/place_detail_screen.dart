import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/services/api_service.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/screens/campus_explore/update_place_screen.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> place;

  const PlaceDetailScreen({super.key, required this.place});

  Future<void> _deletePlace(BuildContext context, int placeId, bool recursive) async {
    try {
      if (recursive) {
        await ApiService.recursiveDeletePlace(placeId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place and children deleted successfully')),
        );
      } else {
        await ApiService.deletePlace(placeId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place deleted successfully')),
        );
      }
      Navigator.pop(context); // Go back to the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting place: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final placeId = place['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(place['name'] ?? 'Place Details'),
        backgroundColor: Colors.indigo,
        actions: authProvider.isLoggedIn
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'update') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdatePlaceScreen(place: place),
                        ),
                      );
                    } else if (value == 'delete') {
                      _deletePlace(context, placeId, false);
                    } else if (value == 'recursive_delete') {
                      _deletePlace(context, placeId, true);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'update',
                      child: Text('Update Place'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Place'),
                    ),
                    const PopupMenuItem(
                      value: 'recursive_delete',
                      child: Text('Recursive Delete'),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${place['name'] ?? 'Not set'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Type: ${place['place_type'] ?? 'Not set'}'),
              Text('Description: ${place['description'] ?? 'Not set'}'),
              Text('History: ${place['history'] ?? 'Not set'}'),
              Text('Establishment Year: ${place['establishment_year']?.toString() ?? 'Not set'}'),
              Text('Relative Location: ${place['relative_location'] ?? 'Not set'}'),
              Text('Latitude: ${place['latitude']?.toString() ?? 'Not set'}'),
              Text('Longitude: ${place['longitude']?.toString() ?? 'Not set'}'),
              Text('Maps Link: ${place['maps_link'] ?? 'Not set'}'),
              Text('University: ${place['university']?.toString() ?? 'Not set'}'),
              Text('Academic Unit: ${place['academic_unit']?.toString() ?? 'Not set'}'),
              Text('Parent: ${place['parent_data'] != null ? place['parent_data']['name'] ?? 'Not set' : 'None'}'),
              Text('Children: ${place['children']?.isEmpty ?? true ? 'None' : place['children'].map((c) => c['name']).join(', ')}'),
              Text('Created By: ${place['created_by'] != null ? place['created_by']['name'] ?? 'Unknown' : 'Unknown'}'),
              Text('Created At: ${place['created_at'] ?? 'Not set'}'),
              Text('Updated At: ${place['updated_at'] ?? 'Not set'}'),
              Text('Approval Status: ${place['approval_status'] ?? 'Not set'}'),
              Text('University Root: ${place['university_root'] == true ? 'Yes' : 'No'}'),
              Text('Academic Unit Root: ${place['academic_unit_root'] == true ? 'Yes' : 'No'}'),
              Text('Media: ${place['media']?.isEmpty ?? true ? 'None' : place['media'].map((m) => m['file_url']).join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}