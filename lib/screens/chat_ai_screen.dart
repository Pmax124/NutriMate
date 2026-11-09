import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/ai_service.dart';

class ChatAIScreen extends StatefulWidget {
  const ChatAIScreen({super.key});

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

class _ChatAIScreenState extends State<ChatAIScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _messageController.clear();

    final profile = context.read<UserProvider>().profile;
    final reply = await AIService.chat(text, profile);

    setState(() {
      _messages.add({'role': 'ai', 'content': reply});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NutriBot 🤖'), backgroundColor: Color(0xFF9C27B0), foregroundColor: Colors.white),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🤖', style: TextStyle(fontSize: 80)),
                          SizedBox(height: 20),
                          Text('Xin chào! Mình là NutriBot', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text('Hỏi mình bất cứ điều gì về dinh dưỡng nhé!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                          SizedBox(height: 30),
                          _SuggestionChip(label: 'Thực đơn giảm cân', onTap: () => _messageController.text = 'Gợi ý thực đơn giảm cân cho tôi'),
                          SizedBox(height: 8),
                          _SuggestionChip(label: 'Ăn gì để tăng cơ?', onTap: () => _messageController.text = 'Ăn gì để tăng cơ?'),
                          SizedBox(height: 8),
                          _SuggestionChip(label: 'Calo trong phở bò?', onTap: () => _messageController.text = '1 tô phở bò bao nhiêu calo?'),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      final msg = _messages[idx];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? Color(0xFF9C27B0) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg['content']!,
                            style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Loading
          if (_isLoading) Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),

          // Input
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Hỏi NutriBot...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Color(0xFF9C27B0),
                  child: IconButton(icon: Icon(Icons.send, color: Colors.white), onPressed: _isLoading ? null : _sendMessage),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(20), border: Border.all(color: Color(0xFF9C27B0))),
        child: Text(label, style: TextStyle(color: Color(0xFF9C27B0))),
      ),
    );
  }
}