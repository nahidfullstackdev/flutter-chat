import 'package:flutter/material.dart';
import 'package:flutter_chat/screens/auth_screen.dart';

import 'package:flutter_chat/screens/mobile_screen.dart';
import 'package:flutter_chat/services/auth/controller/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StreamBuilder(
        stream: ref.watch(authControllerProvider).authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MobileScreen();
          } else {
            return AuthScreen();
          }
        },
      ),
    );
  }
}
