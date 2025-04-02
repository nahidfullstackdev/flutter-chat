import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuthRepository(this._auth, this._firestore, this._storage);

  Future<User?> signUpWithEmail(
    String email,
    String password,
    String name,
    File? image,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      String? imageUrl;
      if (image != null) {
        final ref = _storage.ref().child('profile_image/${user!.uid}.jpg');
        await ref.putFile(image);
        imageUrl = await ref.getDownloadURL();
      }

      final userModel = UserModel(
        uid: user!.uid,
        name: name,
        email: email,
        profilePic: imageUrl ?? '',
        lastMessage: '',
        lastMessageTime: null,
        isOnline: true,
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists ? UserModel.fromMap(doc.data()!) : null;
  }

  Stream<List<UserModel>> getAllUsers() {
    final currentUserId = getCurrentUser()?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) => user.uid != currentUserId) // Exclude current user
          .toList();
    });
  }

  Stream<List<UserModel>> getRecentlyChatUsers() {
    String? currentUserId = getCurrentUser()?.uid;
    if (currentUserId == null) return const Stream.empty();

    return _firestore.collection('chats').snapshots().asyncMap((
      chatSnapshot,
    ) async {
      Set<String> seenUserIds = {}; // Track unique users
      List<UserModel> recentUsers = [];

      for (var chatDoc in chatSnapshot.docs) {
        String chatId = chatDoc.id;

        if (chatId.contains(currentUserId)) {
          // Get messages sorted by timestamp (latest first)
          var messagesSnapshot =
              await _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .get();

          if (messagesSnapshot.docs.isNotEmpty) {
            var lastMessage = messagesSnapshot.docs.first.data();
            List<String> participants = chatId.split('-');
            String otherUserId = participants.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );

            if (otherUserId.isNotEmpty && !seenUserIds.contains(otherUserId)) {
              seenUserIds.add(otherUserId); // Avoid duplicate users

              // Fetch user details
              var userDoc =
                  await _firestore.collection('users').doc(otherUserId).get();
              if (userDoc.exists) {
                recentUsers.add(UserModel.fromMap(userDoc.data()!));
              }
            }
          }
        }
      }
      return recentUsers;
    });
  }

  Future<void> updateProfilePicture(File image) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Upload new image
      final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
      await ref.putFile(image);
      final imageUrl = await ref.getDownloadURL();

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profilePic': imageUrl,
      });
    } catch (e) {
      throw Exception('Failed to update profile picture: $e');
    }
  }

  Stream<UserModel> userData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }

  void setUserState(bool isOnline) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'isOnline': true,
    });
  }
}
