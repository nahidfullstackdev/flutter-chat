import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/models/user_model.dart';
import 'package:flutter_chat/services/auth/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = Provider(
  (ref) => AuthController(authRepository: ref.read(authRepositoryProvider)),
);

class AuthController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required File? image,
  }) async {
    await authRepository.signUpWithEmail(email, password, name, image);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await authRepository.signInWithEmail(email, password);
  }

  void signOut() async {
    await authRepository.signOut();
  }

  Stream authStateChanges() {
    return authRepository.authStateChanges();
  }

  User? getCurrentUser() {
    return authRepository.getCurrentUser();
  }

  Stream<List<UserModel>> getAllUsers() {
    return authRepository.getAllUsers();
  }

  Stream<List<UserModel>> getRecentlyChatUsers() {
    return authRepository.getRecentlyChatUsers();
  }

  Future<void> updateProfilePicture(File image) async {
    await authRepository.updateProfilePicture(image);
  }

  Future<UserModel?> getCurrentUserData() async {
    return await authRepository.getCurrentUserData();
  }

  Stream<UserModel> userDataById(String userId) {
    return authRepository.userData(userId);
  }

  void setUserState(bool isOnline) {
    authRepository.setUserState(isOnline);
  }
}
