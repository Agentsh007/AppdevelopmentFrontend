import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/blood_bank/blood_group_screen.dart';
import 'package:my_app/presentation/screens/blood_bank/donor_screen.dart';
import 'package:my_app/presentation/screens/blood_bank/donor_list_screen.dart';
import 'package:my_app/presentation/screens/blood_bank/requests_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart'; 

class BloodBankScreen extends StatefulWidget {
  const BloodBankScreen({super.key});

  @override
  _BloodBankScreenState createState() => _BloodBankScreenState();
}

class _BloodBankScreenState extends State<BloodBankScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const BloodGroupsScreen(),
    const DonorScreen(),
    const RequestsScreen(),
    const DonorListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        title: const Text('Blood Bank'),
        backgroundColor: Colors.redAccent,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bloodtype), label: 'Blood Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Donor'),
          BottomNavigationBarItem(icon: Icon(Icons.request_page), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Donor List'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}