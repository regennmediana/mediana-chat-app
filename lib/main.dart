import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'chat_room_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDQ-vMWu3Je6xVxWxCT1LF4mD9mfvhVI_k",
      appId: "1:937843166458:web:fc228f2b861ce49e48cd43",
      messagingSenderId: "937843166458",
      projectId: "chat-app-a1a01",
      storageBucket: "chat-app-a1a01.firebasestorage.app",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
     home: ChatRoomScreen(
        chatId: "general_room",
        currentUserId: "user_test_2",
      
      ),
    );
  }
}