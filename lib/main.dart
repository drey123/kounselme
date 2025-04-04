// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/config/env.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/presentation/screens/auth/login_screen.dart';
import 'package:kounselme/presentation/screens/home/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Development toggle - set to true to bypass auth screens
const bool kDevMode =
    true; // Set to false when you want to test normal auth flow

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await Env.initialize();

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    // Continue anyway since we're in dev mode
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for a more modern look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.snowWhite,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KounselMe',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      // Use home screen in dev mode, login screen otherwise
      home: kDevMode ? const HomeScreen() : const LoginScreen(),
    );
  }
}
