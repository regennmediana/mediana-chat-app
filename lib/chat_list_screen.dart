import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_room_screen.dart';
import 'login_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String currentUserId;

  const ChatListScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final rooms = [
      {'id': 'general_room', 'title': 'General Room', 'subtitle': 'Public group chat'},
      {'id': 'tech_talk', 'title': 'Tech Talk', 'subtitle': 'Flutter & Firebase discussions'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0E1621),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17212B),
        title: const Text('Telegram Chats', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF5288C1),
              child: Text(room['title']![0], style: const TextStyle(color: Colors.white)),
            ),
            title: Text(room['title']!, style: const TextStyle(color: Colors.white)),
            subtitle: Text(room['subtitle']!, style: const TextStyle(color: Color(0xFF7F91A4))),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    chatId: room['id']!,
                    currentUserId: currentUserId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}