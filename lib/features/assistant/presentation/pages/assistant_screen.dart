import 'package:flutter/material.dart';
import '../../models/chat_message_model.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
        text: 'Merhaba! Ben Momo. Sana nasıl yardımcı olabilirim?',
        isUser: false),
  ];

  void _sendMessage() {
    final text = _messageController.text;
    if (text.isEmpty) return; // Boş mesaj gönderme

    setState(() {
      // Önce kullanıcının mesajını ekle
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      // Sonra Momo'nun basit cevabını ekle
      _messages.insert(0,
          ChatMessage(text: 'Bu özelliği yakında öğreneceğim!', isUser: false));
    });

    _messageController.clear(); // Mesaj alanını temizle
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momo Asistan'),
      ),
      body: Column(
        children: [
          // Sohbet balonlarının listelendiği alan
          Expanded(
            child: ListView.builder(
              reverse:
                  true, // Listeyi aşağıdan yukarı doğru gösterir (sohbet uygulamaları gibi)
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Yazı yazma alanı
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Tek bir sohbet baloncuğunu oluşturan widget
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      // Kullanıcı mesajları sağa, Momo'nun mesajları sola yaslanacak
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight:
                isUser ? const Radius.circular(4) : const Radius.circular(20),
            bottomLeft:
                !isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  // Alttaki metin giriş alanını oluşturan widget
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Momo\'ya bir şey sor...',
                border: InputBorder.none,
                filled: false,
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
