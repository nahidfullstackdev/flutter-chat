import 'package:flutter_chat/models/message_model.dart';
import 'package:flutter_chat/services/chat/repository/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatControllerProvider = Provider<ChatController>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository);
});

class ChatController {
  ChatRepository chatRepository;
  ChatController(this.chatRepository);

  Future<void> sendMessage(
    String senderId,
    String receiverId,
    ChatMessageModel message,
  ) async {
    await chatRepository.sendMessage(senderId, receiverId, message);
  }

  Stream<List<ChatMessageModel>> getMessages(
    String senderId,
    String receiverId,
  ) {
    return chatRepository.getMessages(senderId, receiverId);
  }
}
