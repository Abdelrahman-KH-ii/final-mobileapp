enum ChatSender { user, ai }

class ChatMessage {
  final String text;
  final ChatSender sender;
  final String time;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.time,
  });
}
