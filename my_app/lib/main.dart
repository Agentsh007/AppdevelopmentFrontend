import 'package:flutter/material.dart';
import 'package:my_app/presentation/screens/blood_bank/blood_bank_screen.dart';
import 'package:my_app/presentation/screens/edit_profile_screen.dart';
import 'package:my_app/presentation/screens/profile_screen.dart';
import 'package:my_app/presentation/screens/test_fetch_screen.dart';
import 'package:my_app/presentation/screens/test_fetch_screen2.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/screens/login_and_register/login_screen.dart';
import 'package:my_app/presentation/screens/login_and_register/register_screen.dart';
import 'package:my_app/presentation/screens/login_and_register/verify_email_screen.dart';
import 'package:my_app/presentation/screens/home_screen.dart';
import 'package:my_app/presentation/screens/splash_screen.dart';
import 'package:my_app/data/repositories/auth_repository.dart';
import 'package:my_app/domain/providers/auth_provider.dart';

void main() {
  runApp(const CampusConnectApp());
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Campus Connect',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/verify-email': (context) => const VerifyEmailScreen(),
          '/home': (context) => const HomeScreen(),
          '/blood-bank':(context)=> const BloodBankScreen(),
          '/profile': (context) => const ProfileScreen(), // Added profile route
          '/edit-profile':(context)=> const EditProfileScreen(),
          '/test-fetch': (context) => const TestFetchScreen(),
          '/test-fetch2': (context) => const TestFetchScreen2(),
        },
      ),
    );
  }
}