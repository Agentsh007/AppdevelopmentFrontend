import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practice_1/colors/colors.dart';
import 'package:practice_1/models/lost_item.dart';
import 'package:practice_1/services/api_service.dart';
import 'package:practice_1/services/session_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportLostItemScreen extends StatefulWidget {
  final VoidCallback onSubmit;

  const ReportLostItemScreen({super.key, required this.onSubmit});

  @override
  State<ReportLostItemScreen> createState() => _ReportLostItemScreenState();
}

class _ReportLostItemScreenState extends State<ReportLostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final SessionService _sessionService = SessionService();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _reportLostItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = await _sessionService.getSessionToken();
      final email = await _sessionService.getSessionEmail();
      if (token != null && email != null) {
        final imagePath = await _apiService.uploadImage(_selectedImage!, token);
        final lostItem = LostItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          description: _descriptionController.text,
          location: _locationController.text,
          userEmail: email,
          imagePath: imagePath,
          found: false,
        );
        await _apiService.reportLostItem(lostItem, token);
        _nameController.clear();
        _descriptionController.clear();
        _locationController.clear();
        setState(() => _selectedImage = null);
        widget.onSubmit();
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reporting lost item: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Lost Item',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryText(context),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _descriptionController.clear();
              _locationController.clear();
              setState(() => _selectedImage = null);
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background(context).withOpacity(0.8),
              AppColors.background(context),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: AppColors.background(context).withOpacity(0.9),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.label,
                        color: AppColors.buttonAccent(context),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter item name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: AppColors.background(context).withOpacity(0.9),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.description,
                        color: AppColors.buttonAccent(context),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter description' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: AppColors.background(context).withOpacity(0.9),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: AppColors.buttonAccent(context),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter location' : null,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondaryText(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _selectedImage == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: AppColors.secondaryText(context).withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Select Image',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.secondaryText(context),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _reportLostItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonAccent(context),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Submit',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}