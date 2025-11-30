class ChatMessage {
  final String text;
  final bool isUser; // Mesaj kullanıcıdan mı geldi, Momo'dan mı?

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}
