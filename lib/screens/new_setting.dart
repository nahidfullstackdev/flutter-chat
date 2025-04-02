import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/screens/auth_screen.dart';
import 'package:flutter_chat/screens/profile_screen.dart';
import 'package:flutter_chat/services/auth/controller/auth_controller.dart';
import 'package:flutter_chat/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider.notifier);
    bool isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    void logOut() {
      ref.read(authControllerProvider).signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile section
                  FutureBuilder(
                    future:
                        ref.watch(authControllerProvider).getCurrentUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading user'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                          child: Text('No user data available'),
                        );
                      }

                      final user = snapshot.data;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,

                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: CachedNetworkImageProvider(
                            user?.profilePic ??
                                'https://example.com/default_profile_pic.png',
                          ),
                        ),
                        title: Text(
                          user?.name ?? 'User Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          user?.email ?? 'Email',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Dark Mode toggle
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF8A56FF),
                      ),
                      child: const Icon(
                        Icons.dark_mode,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      "Dark Mode",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                      activeColor: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _buildSettingItem(
                    icon: Icons.notifications,
                    iconColor: Colors.redAccent,
                    title: "Notifications",
                  ),

                  _buildSettingItem(
                    icon: Icons.lock,
                    iconColor: Colors.orange,
                    title: "Privacy",
                  ),

                  _buildSettingItem(
                    icon: Icons.security,
                    iconColor: Colors.lightBlue,
                    title: "Security",
                  ),

                  _buildSettingItem(
                    icon: Icons.home,
                    iconColor: Colors.green,
                    title: "Main",
                  ),

                  _buildSettingItem(
                    icon: Icons.palette,
                    iconColor: Colors.deepPurple,
                    title: "Appearance",
                  ),

                  _buildSettingItem(
                    icon: Icons.language,
                    iconColor: Colors.amber,
                    title: "Language",
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "English",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),

                  _buildSettingItem(
                    icon: Icons.question_answer,
                    iconColor: Colors.redAccent,
                    title: "Ask a Question",
                  ),

                  _buildSettingItem(
                    icon: Icons.help,
                    iconColor: Colors.teal,
                    title: "FAQ",
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    title: Text(
                      'Log Out',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey),
                    ),
                    onTap: logOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconColor.withOpacity(0.2),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
