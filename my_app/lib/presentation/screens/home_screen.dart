import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/blood_bank/blood_bank_screen.dart';
import 'package:my_app/presentation/screens/campus_explore/campus_explore_screen.dart';
import 'package:my_app/presentation/screens/lost_and_found/lost_and_found_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/widgets/custom_feature_card.dart';
import 'login_and_register/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent, Colors.blue],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Campus App',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
        body: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16.0),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            CustomFeatureCard(
              icon: Icons.explore,
              title: 'Campus Explore',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CampusExploreScreen(),
                  ),
                );
              },
              animationDuration: const Duration(milliseconds: 500),
            ),
            CustomFeatureCard(
              icon: Icons.local_hospital,
              title: 'Blood Bank',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BloodBankScreen(),
                  ),
                );
              },
              animationDuration: const Duration(milliseconds: 600),
            ),
            CustomFeatureCard(
              icon: Icons.search,
              title: 'Lost and Found',
              onTap: () {
                if (authProvider.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LostAndFoundHubScreen(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              animationDuration: const Duration(milliseconds: 700),
            ),
            CustomFeatureCard(
              icon: Icons.report,
              title: 'Report to Admin',
              onTap: () {
                if (authProvider.isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report to Admin - To be implemented'),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              animationDuration: const Duration(milliseconds: 800),
            ),
            // Add a test button
            CustomFeatureCard(
              icon: Icons.settings,
              title: 'Test Fetch',
              onTap: () {
                Navigator.pushNamed(context, '/test-fetch');
              },
              animationDuration: const Duration(milliseconds: 900),
            ),
            // Add a test button
            CustomFeatureCard(
              icon: Icons.settings,
              title: 'Test Fetch2',
              onTap: () {
                Navigator.pushNamed(context, '/test-fetch2');
              },
              animationDuration: const Duration(milliseconds: 900),
            ),
          ],
        ),
      ),
    );
  }
}
