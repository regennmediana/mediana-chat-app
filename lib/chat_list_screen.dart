import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_room_screen.dart';
import 'login_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String currentUserId;

  const ChatListScreen({super.key, required this.currentUserId});

  Future<void> _showCreateRoomDialog(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF17212B),
          title: const Text('Create New Room', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter room name',
              hintStyle: TextStyle(color: Color(0xFF7F91A4)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF5288C1)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF7F91A4))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5288C1)),
              onPressed: () async {
                final roomName = controller.text.trim();
                if (roomName.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('chats').add({
                    'name': roomName,
                    'members': [currentUserId],
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5288C1),
        onPressed: () => _showCreateRoomDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading rooms', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No chat rooms available. Tap + to create one!', style: TextStyle(color: Color(0xFF7F91A4))),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final roomDoc = docs[index];
              final roomData = roomDoc.data() as Map<String, dynamic>;
              final String roomName = roomData['name'] ?? 'General Room';
              final List members = roomData['members'] ?? [];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF5288C1),
                  child: Text(
                    roomName.isNotEmpty ? roomName[0].toUpperCase() : 'C',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  roomName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${members.length} ${members.length == 1 ? "member" : "members"}',
                  style: const TextStyle(color: Color(0xFF7F91A4)),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatRoomScreen(
                        chatId: roomDoc.id,
                        currentUserId: currentUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}