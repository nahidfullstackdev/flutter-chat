import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/models/message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(FirebaseFirestore.instance);
});

class ChatRepository {
  final FirebaseFirestore _firestore;
  ChatRepository(this._firestore);

  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  Future<void> sendMessage(
    String senderId,
    String receiverId,
    ChatMessageModel message,
  ) async {
    try {
      String chatId = getChatId(senderId, receiverId);
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

      // Store last message in both users' documents
      await _firestore.collection('users').doc(senderId).update({
        'lastMessage': message.message,
        'lastMessageTime': message.timestamp,
      });

      await _firestore.collection('users').doc(receiverId).update({
        'lastMessage': message.message,
        'lastMessageTime': message.timestamp,
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ChatMessageModel>> getMessages(
    String senderId,
    String receiverId,
  ) {
    String chatId = getChatId(senderId, receiverId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatMessageModel.fromMap(doc.data()))
                  .toList(),
        );
  }
}
