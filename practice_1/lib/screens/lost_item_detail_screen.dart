import 'package:flutter/material.dart';
import 'package:practice_1/colors/colors.dart';
import 'package:practice_1/models/lost_item.dart';
import 'package:practice_1/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LostItemDetailScreen extends StatelessWidget {
  final LostItem item;
  final VoidCallback onMarkAsFound;
  final VoidCallback onDelete;
  final bool isOwner;
  final String? currentUserEmail; // Assuming this is how you get the current user's email
  const LostItemDetailScreen({
    super.key,
    required this.item,
    required this.onMarkAsFound,
    required this.onDelete,
    required this.isOwner,
    required  this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lost Item Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryText(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imagePath.isNotEmpty
                    ? Image.network(
                        '${ApiService.baseUrl}${item.imagePath}',
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 300,
                          width: double.infinity,
                          color: AppColors.secondaryText(context).withOpacity(0.1),
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                      )
                    : Container(
                        height: 300,
                        width: double.infinity,
                        color: AppColors.secondaryText(context).withOpacity(0.1),
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description: ${item.description}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${item.found ? 'Found' : 'Lost'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: item.found ? Colors.green : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 16),
              if (currentUserEmail != item.userEmail && !item.found)
                ElevatedButton(
                  onPressed: onMarkAsFound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Mark as Found',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (isOwner)
                ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}