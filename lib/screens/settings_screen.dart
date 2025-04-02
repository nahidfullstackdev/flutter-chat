import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/screens/auth_screen.dart';
import 'package:flutter_chat/screens/profile_screen.dart';
import 'package:flutter_chat/services/auth/controller/auth_controller.dart';
import 'package:flutter_chat/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MySettings extends ConsumerWidget {
  const MySettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeNotifier = ref.watch(themeProvider.notifier);
    bool isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    void logOut() {
      ref.watch(authControllerProvider).signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text('Settings'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _mySettingList(context, 'Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            }),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                'Dark Mode',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey),
              ),
              trailing: CupertinoSwitch(
                value: isDarkMode,
                onChanged: (value) {
                  themeNotifier.toggleTheme();
                },
              ),
            ),
            Spacer(),
            _mySettingList(context, 'Log Out', logOut),
          ],
        ),
      ),
    );
  }
}

Widget _mySettingList(BuildContext context, String text, VoidCallback onTap) {
  return ListTile(
    title: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Colors.grey),
    ),
    onTap: onTap,
  );
}
