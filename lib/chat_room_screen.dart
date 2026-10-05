import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderId': widget.currentUserId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Dialog to update room name in Firestore
  Future<void> _showEditRoomNameDialog(String currentName) async {
    final controller = TextEditingController(text: currentName);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF17212B),
          title: const Text('Edit Room Name', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter new room name',
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
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .set({'name': newName}, SetOptions(merge: true));

                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
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
        elevation: 1,
        titleSpacing: 0,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatId)
              .snapshots(),
          builder: (context, snapshot) {
            final chatData = snapshot.data?.data() as Map<String, dynamic>?;
            final roomName = chatData?['name'] ?? 'General Room';
            final List members = chatData?['members'] ?? [];
            final int memberCount = members.length;
            final avatarInitial = roomName.isNotEmpty ? roomName[0].toUpperCase() : 'G';

            return InkWell(
              onTap: () => _showEditRoomNameDialog(roomName),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF5288C1),
                    child: Text(
                      avatarInitial,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            roomName,
                            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 14, color: Color(0xFF7F91A4)),
                        ],
                      ),
                      Text(
                        '$memberCount ${memberCount == 1 ? "member" : "members"}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF7F91A4)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Color(0xFF7F91A4)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Color(0xFF7F91A4)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages', style: TextStyle(color: Colors.white)));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final bool isMe = data['senderId'] == widget.currentUserId;
                    final String text = data['text'] ?? '';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF2B5278) : const Color(0xFF182533),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          text,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: const Color(0xFF17212B),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied_alt, color: Color(0xFF7F91A4)),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle: TextStyle(color: Color(0xFF7F91A4)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Color(0xFF7F91A4)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF5288C1)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}