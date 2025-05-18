import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/blood_bank/donor_list_screen.dart';
import 'package:my_app/presentation/screens/blood_bank/donor_profile_screen.dart';
import 'package:my_app/presentation/screens/blood_bank/donor_register_screen.dart';
import 'package:my_app/presentation/screens/blood_bank/donor_withdraw_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
class DonorScreen extends StatefulWidget {
  const DonorScreen({super.key});

  @override
  _DonorScreenState createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DonorRegisterScreen(),
    const DonorProfileScreen(),
    const DonorWithdrawScreen(),
    const DonorListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, '/login');
      });
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Management'),
        backgroundColor: Colors.redAccent,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Register'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.remove_circle), label: 'Withdraw'),
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