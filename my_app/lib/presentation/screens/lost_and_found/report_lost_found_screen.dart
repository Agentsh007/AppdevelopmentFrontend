import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:my_app/presentation/widgets/custom_text_field.dart';
import 'package:my_app/data/models/university_model.dart';
import 'dart:developer' as developer;

class ReportLostFoundScreen extends StatefulWidget {
  const ReportLostFoundScreen({Key? key}) : super(key: key);

  @override
  _ReportLostFoundScreenState createState() => _ReportLostFoundScreenState();
}

class _ReportLostFoundScreenState extends State<ReportLostFoundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  String _postType = 'lost';
  File? _mediaFile;
  bool _isLoading = false;
  int? _selectedUniversityId;
  List<UniversityModel> _universities = [];

  @override
  void initState() {
    super.initState();
    _fetchUniversities();
  }

  Future<void> _fetchUniversities() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    try {
      await authProvider.fetchUniversities();
      setState(() {
        _universities = authProvider.universities;
        if (_universities.isNotEmpty) {
          _selectedUniversityId = _universities.first.id; // Default to first university
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching universities: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() || _selectedUniversityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields and select a university'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        Navigator.pushNamed(context, '/login');
        return;
      }

      final data = {
        'university': _selectedUniversityId.toString(),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'approximate_time': _timeController.text,
        if (_postType == 'lost') 'lost_date': _dateController.text,
        if (_postType == 'found') 'found_date': _dateController.text,
        'media': _mediaFile,
      };

      // Log the data being sent
      developer.log('Submitting report with data: $data', name: 'ReportLostFoundScreen');

      if (_postType == 'lost') {
        await ApiService.createLostItem(data);
      } else {
        await ApiService.createFoundItem(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item reported successfully')));
      Navigator.pop(context);
    } catch (e) {
      // Log the exception
      developer.log('Error submitting report: $e', name: 'ReportLostFoundScreen');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error reporting item: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Lost or Found Item'),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          _universities.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedUniversityId,
                        isExpanded: true,
                        items:
                            _universities.map((university) {
                              return DropdownMenuItem<int>(
                                value: university.id,
                                child: Text(university.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUniversityId = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Select University',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null
                                    ? 'Please select a university'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButton<String>(
                        value: _postType,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'lost',
                            child: Text('Lost Item'),
                          ),
                          DropdownMenuItem(
                            value: 'found',
                            child: Text('Found Item'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _postType = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _titleController,
                        labelText: 'Title',
                        obscureText: false,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: 'Description',
                        obscureText: false,
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Description is required'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _locationController,
                        labelText: 'Location',
                        obscureText: false,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Location is required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _dateController,
                        labelText:
                            _postType == 'lost' ? 'Lost Date' : 'Found Date',
                        obscureText: false,
                        keyboardType: TextInputType.datetime,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Date is required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _timeController,
                        labelText: 'Approximate Time',
                        obscureText: false,
                        keyboardType: TextInputType.datetime,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Time is required' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text(
                          _mediaFile == null ? 'Pick Image' : 'Image Selected',
                        ),
                      ),
                      if (_mediaFile != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Image.file(
                            _mediaFile!,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: _submitReport,
                            child: Text('Submit Report'),
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}