import 'package:flutter/material.dart';
import 'package:practice_1/colors/colors.dart';
import 'package:practice_1/screens/home_screen.dart';
import 'package:practice_1/screens/splash_screen.dart';
import 'package:practice_1/screens/login_screen.dart';
import 'package:practice_1/screens/lost_and_found_screen.dart';
import 'package:practice_1/screens/report_admin_screen.dart';
import 'package:practice_1/screens/campus_explore_screen.dart';
import 'package:practice_1/screens/notification_screen.dart';
import 'package:practice_1/screens/profile_screen.dart';
import 'package:practice_1/screens/search_screen.dart';
import 'package:practice_1/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Campus Connect',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: AppColors.primaryTextLight),
              bodyMedium: TextStyle(color: AppColors.secondaryTextLight),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.backgroundLight,
              foregroundColor: AppColors.primaryTextLight,
            ),
            cardTheme: CardTheme(
              color: AppColors.cardBackgroundLight,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: AppColors.backgroundDark,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: AppColors.primaryTextDark),
              bodyMedium: TextStyle(color: AppColors.secondaryTextDark),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.backgroundDark,
              foregroundColor: AppColors.primaryTextDark,
            ),
            cardTheme: CardTheme(
              color: AppColors.cardBackgroundDark,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          themeMode: mode,
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/lost-and-found': (context) => const LostAndFoundScreen(),
            '/report-admin': (context) => const ReportAdminScreen(),
            '/campus-explore': (context) => const CampusExploreScreen(),
            '/notifications': (context) => const NotificationScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/search': (context) => const SearchScreen(),
            '/splash': (context) => const SplashScreen(),
          },
        );
      },
    );
  }
}