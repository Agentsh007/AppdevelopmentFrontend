import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/services/api_service.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';

class UpdatePlaceScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const UpdatePlaceScreen({super.key, required this.place});

  @override
  _UpdatePlaceScreenState createState() => _UpdatePlaceScreenState();
}

class _UpdatePlaceScreenState extends State<UpdatePlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _historyController;
  late TextEditingController _establishmentYearController;
  late TextEditingController _relativeLocationController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _mapsLinkController;
  late TextEditingController _placeTypeController;
  late TextEditingController _universityController;
  late TextEditingController _academicUnitController;
  late TextEditingController _parentController;
  bool _universityRoot = false;
  bool _academicUnitRoot = false;
  List<File> _mediaFiles = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _placeTypes = [];
  List<Map<String, dynamic>> _places = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place['name']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.place['description']?.toString() ?? '');
    _historyController = TextEditingController(text: widget.place['history']?.toString() ?? '');
    _establishmentYearController = TextEditingController(text: widget.place['establishment_year']?.toString() ?? '');
    _relativeLocationController = TextEditingController(text: widget.place['relative_location']?.toString() ?? '');
    _latitudeController = TextEditingController(text: widget.place['latitude']?.toString() ?? '');
    _longitudeController = TextEditingController(text: widget.place['longitude']?.toString() ?? '');
    _mapsLinkController = TextEditingController(text: widget.place['maps_link']?.toString() ?? '');
    _placeTypeController = TextEditingController(text: widget.place['place_type']?.toString() ?? '');
    _universityController = TextEditingController(text: widget.place['university']?.toString() ?? '');
    _academicUnitController = TextEditingController(text: widget.place['academic_unit']?.toString() ?? '');
    _parentController = TextEditingController(text: widget.place['parent']?.toString() ?? '');
    _universityRoot = widget.place['university_root'] ?? false;
    _academicUnitRoot = widget.place['academic_unit_root'] ?? false;
    _fetchPlaceTypes();
    _fetchPlaces();
    _fetchUniversitiesAndAcademicUnits();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _historyController.dispose();
    _establishmentYearController.dispose();
    _relativeLocationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _mapsLinkController.dispose();
    _placeTypeController.dispose();
    _universityController.dispose();
    _academicUnitController.dispose();
    _parentController.dispose();
    super.dispose();
  }

  Future<void> _fetchPlaceTypes() async {
    try {
      final placeTypes = await ApiService.fetchPlaceTypes();
      setState(() {
        _placeTypes = placeTypes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching place types: $e')),
      );
    }
  }

  Future<void> _fetchPlaces() async {
    try {
      final places = await ApiService.fetchPlaces();
      setState(() {
        _places = places;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching places: $e')),
      );
    }
  }

  Future<void> _fetchUniversitiesAndAcademicUnits() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.fetchUniversities();
      if (authProvider.universities.isNotEmpty && _universityController.text.isNotEmpty) {
        await authProvider.fetchAcademicUnits(int.parse(_universityController.text));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching universities/academic units: $e')),
      );
    }
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _mediaFiles = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _updatePlace() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'history': _historyController.text,
        'establishment_year': _establishmentYearController.text.isNotEmpty ? int.parse(_establishmentYearController.text) : null,
        'relative_location': _relativeLocationController.text,
        'latitude': _latitudeController.text.isNotEmpty ? double.parse(_latitudeController.text) : null,
        'longitude': _longitudeController.text.isNotEmpty ? double.parse(_longitudeController.text) : null,
        'maps_link': _mapsLinkController.text,
        'place_type': _placeTypeController.text,
        'university': _universityController.text.isNotEmpty ? int.parse(_universityController.text) : null,
        'academic_unit': _academicUnitController.text.isNotEmpty ? int.parse(_academicUnitController.text) : null,
        'parent': _parentController.text.isNotEmpty ? int.parse(_parentController.text) : null,
        'university_root': _universityRoot,
        'academic_unit_root': _academicUnitRoot,
        'media_files': _mediaFiles,
      };
      await ApiService.updatePlace(widget.place['id'], data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place update submitted for approval')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating place: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Place'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Name',
                obscureText: false,
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                obscureText: false,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _historyController,
                labelText: 'History',
                obscureText: false,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _establishmentYearController,
                labelText: 'Establishment Year',
                obscureText: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final year = int.tryParse(value);
                    if (year == null || year > 2025) return 'Invalid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _relativeLocationController,
                labelText: 'Relative Location',
                obscureText: false,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _latitudeController,
                labelText: 'Latitude',
                obscureText: false,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _longitudeController,
                labelText: 'Longitude',
                obscureText: false,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _mapsLinkController,
                labelText: 'Maps Link',
                obscureText: false,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _placeTypeController.text.isEmpty ? null : _placeTypeController.text,
                hint: const Text('Select Place Type'),
                items: _placeTypes
                    .map<DropdownMenuItem<String>>((type) => DropdownMenuItem<String>(
                          value: type['name'] as String,
                          child: Text(type['name']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _placeTypeController.text = value ?? '';
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Place Type',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Place type is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _universityController.text.isEmpty ? null : _universityController.text,
                hint: const Text('Select University'),
                items: authProvider.universities
                    .map((uni) => DropdownMenuItem(
                          value: uni.id.toString(),
                          child: Text(uni.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _universityController.text = value ?? '';
                    if (value != null) {
                      authProvider.fetchAcademicUnits(int.parse(value));
                    }
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'University',
                ),
                validator: (value) => value == null || value.isEmpty ? 'University is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _academicUnitController.text.isEmpty ? null : _academicUnitController.text,
                hint: const Text('Select Academic Unit'),
                items: authProvider.academicUnits
                    .map((unit) => DropdownMenuItem(
                          value: unit.id.toString(),
                          child: Text(unit.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _academicUnitController.text = value ?? '';
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Academic Unit',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _parentController.text.isEmpty ? null : _parentController.text,
                hint: const Text('Select Parent Place'),
                items: _places
                    .map((place) => DropdownMenuItem(
                          value: place['id'].toString(),
                          child: Text(place['name']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _parentController.text = value ?? '';
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Parent Place',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _universityRoot,
                    onChanged: (value) => setState(() => _universityRoot = value!),
                  ),
                  const Text('University Root'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _academicUnitRoot,
                    onChanged: (value) => setState(() => _academicUnitRoot = value!),
                  ),
                  const Text('Academic Unit Root'),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickMedia,
                child: const Text('Pick Media Files'),
              ),
              const SizedBox(height: 8),
              Text('Selected Files: ${_mediaFiles.length}'),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updatePlace,
                      child: const Text('Update Place'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}