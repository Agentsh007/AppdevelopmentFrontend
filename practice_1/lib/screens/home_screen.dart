import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice_1/colors/colors.dart';
import 'package:practice_1/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Campus Connect',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryText(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            ModernCardButton(
              text: 'Lost & Found',
              icon: Icons.search,
              onPressed: () => Navigator.pushNamed(context, '/lost-and-found'),
            ),
            ModernCardButton(
              text: 'Campus Explore',
              icon: Icons.map,
              onPressed: () => Navigator.pushNamed(context, '/campus-explore'),
            ),
            ModernCardButton(
              text: 'Report Problem',
              icon: Icons.report,
              onPressed: () => Navigator.pushNamed(context, '/report-admin'),
            ),
            ModernCardButton(
              text: 'Blood Donation',
              icon: Icons.favorite,
              onPressed: () => Navigator.pushNamed(context, '/campus-explore'),
            ),
          ],
        ),
      ),
    );
  }
}