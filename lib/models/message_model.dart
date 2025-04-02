import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String senderId;
  final String message;
  final Timestamp timestamp;

  ChatMessageModel({
    required this.senderId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> data) {
    return ChatMessageModel(
      senderId: data['senderId'],
      message: data['message'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'senderId': senderId, 'message': message, 'timestamp': timestamp};
  }
}
