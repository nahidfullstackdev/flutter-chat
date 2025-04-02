import 'package:flutter/material.dart';
import 'package:flutter_chat/models/user_model.dart';
import 'package:flutter_chat/screens/new_setting.dart';
import 'package:flutter_chat/services/auth/controller/auth_controller.dart';
import 'package:flutter_chat/widgets/contact_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileScreen extends ConsumerStatefulWidget {
  const MobileScreen({super.key});

  @override
  ConsumerState<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends ConsumerState<MobileScreen>
    with WidgetsBindingObserver {
  // WidgetsBindingObserver is to check the user state whether online or not..
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<UserModel> _filterUsers(List<UserModel> users, String query) {
    if (query.isEmpty) return users;

    return users.where((user) {
      final name = user.name.toLowerCase() ?? '';
      final email = user.email.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return name.contains(searchLower) || email.contains(searchLower);
    }).toList();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // related to -> WidgetsBindingObserver is to check the user state whether online or not..
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Chat App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // serach bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                onChanged:
                    (value) => setState(() {
                      _searchQuery = value;
                    }),
              ),
            ),
            const SizedBox(height: 20),
            // All Users Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'All Users',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: ref.read(authControllerProvider).getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }
                  final filteredUsers = _filterUsers(
                    snapshot.data!,
                    _searchQuery,
                  );
                  if (filteredUsers.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }
                  return ContactList(contacts: filteredUsers);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
