import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/models/message_model.dart';
import 'package:flutter_chat/services/auth/controller/auth_controller.dart';
import 'package:flutter_chat/services/chat/controller/chat_controller.dart';
import 'package:flutter_chat/widgets/my_message_card.dart';
import 'package:flutter_chat/widgets/sender_message_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.name,
    required this.profilePic,
  });

  final String senderId;
  final String receiverId;
  final String name;
  final String profilePic;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();

    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Scroll to the bottom when the input field is focused
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut, // Smooth transition
      );
    }
  }

  void _sendMessage() {
    if (messageController.text.trim().isNotEmpty) {
      final message = ChatMessageModel(
        senderId: widget.senderId,
        message: messageController.text.trim(),
        timestamp: Timestamp.now(),
      );
      ref
          .read(chatControllerProvider)
          .sendMessage(widget.senderId, widget.receiverId, message);
      messageController.clear();

      // Scroll to the bottom after sending a message
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: StreamBuilder(
          stream: ref
              .read(authControllerProvider)
              .userDataById(widget.receiverId),
          builder: (context, snapshot) {
            bool isOnline = snapshot.data!.isOnline;
            if (snapshot.connectionState == ConnectionState.done) {
              return CircularProgressIndicator();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 13,
                    color: isOnline ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              // Handle video call action
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // Handle voice call action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: ref
                  .read(chatControllerProvider)
                  .getMessages(widget.senderId, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final ChatMessageModel message = snapshot.data![index];
                    bool isMe = message.senderId == widget.senderId;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child:
                          isMe
                              ? MyMessageCard(
                                message: message.message,
                                time: message.timestamp,
                              )
                              : SenderMessageCard(
                                message: message.message,
                                time: message.timestamp,
                              ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
