// lib/chat_test_app.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/config/env.dart';
import 'package:kounselme/config/theme_improved.dart';
import 'package:kounselme/data/service_factory.dart';
import 'package:kounselme/presentation/screens/chat/chat_screen.dart';

/// This is a standalone entry point for testing the chat functionality
/// without being affected by other screens that might have errors.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await Env.initialize();

  // Force mock backend for testing
  Env.setUseMockData(true);

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

  runApp(const ProviderScope(child: ChatTestApp()));
}

class ChatTestApp extends StatelessWidget {
  const ChatTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KounselMe Chat Test',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      // Go directly to the chat screen
      home: ChatScreen(sessionDuration: const Duration(minutes: 30)),
    );
  }
}
