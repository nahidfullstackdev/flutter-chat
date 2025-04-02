import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/auth_gate.dart';
import 'package:flutter_chat/firebase_options.dart';
import 'package:flutter_chat/responsive/responsive_layout.dart';
import 'package:flutter_chat/screens/mobile_screen.dart';
import 'package:flutter_chat/screens/web_screen.dart';
import 'package:flutter_chat/theme/app_theme.dart';
import 'package:flutter_chat/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider); // Watch the theme state
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Chat App',
      theme: AppTheme.lightThemeMode,
      themeMode: themeMode, // Use the theme mode from the provider
      darkTheme: AppTheme.darkThemeMode,
      home: const ResponsiveLayout(
        webScreenLayout: WebScreen(),
        mobileScreenLayout: AuthGate(),
      ),
    );
  }
}
