import 'package:flutter/material.dart';
import 'dart:async'; 

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Chào bạn! Tôi là trợ lý ảo. Bạn cần giúp gì?',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendPressed() {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      return;
    }

    _controller.clear();

    final userMessage = ChatMessage(text: text, isUser: true);

    setState(() {
      _messages.add(userMessage);
    });
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      String botReply;
      final lowerCaseText = text.toLowerCase();

      if (lowerCaseText.contains('hello') || lowerCaseText.contains('chào')) {
        botReply = 'Chào bạn! Chúc bạn một ngày tốt lành.';
      } else if (lowerCaseText.contains('bạn là ai') ||
          lowerCaseText.contains('tên gì')) {
        botReply = 'Tôi là trợ lý ảo học tập, được tạo ra để hỗ trợ bạn!';
      } else if (lowerCaseText.contains('làm được gì') ||
          lowerCaseText.contains('chức năng')) {
        botReply =
            'Hiện tại, tôi có thể trò chuyện đơn giản. Bạn cũng có thể dùng các công cụ như tính GPA và đồng hồ Pomodoro trong ứng dụng.';
      } else if (lowerCaseText.contains('pomodoro')) {
        botReply =
            'Pomodoro là một phương pháp quản lý thời gian. Bạn làm việc tập trung trong 25 phút, sau đó nghỉ 5 phút. Bạn có thể thử nó ở mục "Công cụ" đó!';
      } else if (lowerCaseText.contains('gpa')) {
        botReply =
            'GPA (Grade Point Average) là điểm trung bình học tập của bạn. Hãy dùng công cụ "Tính điểm GPA" để ước tính nhé!';
      } else if (lowerCaseText.contains('mấy giờ') ||
          lowerCaseText.contains('thời gian')) {
        final now = DateTime.now();
        final timeString =
            "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
        botReply = 'Bây giờ là $timeString.';
      } else if (lowerCaseText.contains('tạm biệt') ||
          lowerCaseText.contains('cảm ơn')) {
        botReply = 'Rất vui được giúp bạn! Tạm biệt.';
      } else {
        botReply =
            'Xin lỗi, tôi chưa hiểu ý bạn. Tôi chỉ là một chatbot đơn giản.';
      }

      final botMessage = ChatMessage(text: botReply, isUser: false);

      setState(() {
        _messages.add(botMessage);
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Chatbot hỗ trợ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: message.isUser ? Colors.red[100] : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.black87, fontSize: 16.0),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onSubmitted: (_) => _handleSendPressed(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.red,
            onPressed: _handleSendPressed,
          ),
        ],
      ),
    );
  }
}