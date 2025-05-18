import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/screens/campus_explore/place_list_screen.dart';
import 'package:my_app/presentation/screens/campus_explore/search_place_screen.dart';
import 'package:my_app/presentation/screens/campus_explore/place_types_screen.dart';
import 'package:my_app/presentation/screens/campus_explore/create_place_screen.dart';
import 'package:my_app/presentation/widgets/custom_feature_card.dart';

class CampusExploreScreen extends StatelessWidget {
  const CampusExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);
    // if (!authProvider.isLoggedIn) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Navigator.pushNamed(context, '/login');
    //   });
    //   return Container();
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Explore'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            CustomFeatureCard(
              icon: Icons.place,
              title: 'List Places',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaceListScreen()),
                );
              },
              iconColor: Colors.indigo,
            ),
            CustomFeatureCard(
              icon: Icons.search,
              title: 'Search Places',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPlaceScreen()),
                );
              },
              iconColor: Colors.indigo,
            ),
            CustomFeatureCard(
              icon: Icons.category,
              title: 'Place Types',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlaceTypesScreen()),
                );
              },
              iconColor: Colors.indigo,
            ),
            CustomFeatureCard(
              icon: Icons.add_location,
              title: 'Create Place',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePlaceScreen()),
                );
              },
              iconColor: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }
}