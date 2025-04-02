import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/colors.dart';

import 'package:flutter_chat/models/user_model.dart';
import 'package:flutter_chat/screens/chat_screen.dart';
import 'package:intl/intl.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key, required this.contacts});

  final List<UserModel> contacts;

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime); // Format as "12:30 PM"
  }

  @override
  Widget build(BuildContext context) {
    final currenUserId = FirebaseAuth.instance.currentUser?.uid;
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final UserModel contact = contacts[index];
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            senderId: currenUserId!,
                            name: contact.name,
                            receiverId: contact.uid,
                            profilePic: contact.profilePic,
                          ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(contact.profilePic),
                    ),
                    title: Text(contact.name),
                    subtitle: Text(
                      contact.lastMessage.isNotEmpty
                          ? contact.lastMessage
                          : 'No messages yet', // Show last message
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      formatTimestamp(contact.lastMessageTime),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Divider(
                color: dividerColor,
                indent: 20,
                endIndent: 20,
                thickness: .09,
              ),
            ],
          );
        },
      ),
    );
  }
}
