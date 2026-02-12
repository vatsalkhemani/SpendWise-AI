import 'package:flutter/material.dart';
import '../services/azure_openai_service.dart';
import '../services/expense_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final AzureOpenAIService _aiService = AzureOpenAIService();
  final ExpenseService _expenseService = ExpenseService();
  final List<ChatMessage> _messages = [
    ChatMessage(
      content: '👋 Hi! I\'m your AI financial assistant. Ask me anything about your spending habits, patterns, or get personalized insights!',
      isFromUser: false,
      timestamp: DateTime.now(),
    ),
  ];
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI EXPENSE TRACKER', style: TextStyle(fontSize: 16)),
            Text(
              'Minimalist AI-powered expense tracking',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Ask AI for Insights header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ask AI for Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Ask about spending patterns, categories, trends...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (text) => _sendQuery(),
                      ),
                    ),
                    IconButton(
                      onPressed: _isProcessing ? null : _sendQuery,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send, color: Color(0xFFFFD60A)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'SUGGESTED PROMPTS:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPromptChip('What\'s my total spending this month?'),
                    _buildPromptChip('Which category do I spend most on?'),
                    _buildPromptChip('What\'s my average transaction?'),
                    _buildPromptChip('How much did I spend on food?'),
                    _buildPromptChip('Any unusual spending patterns?'),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _sendQuery();
      },
      child: Chip(
        label: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  Future<void> _sendQuery() async {
    final query = _controller.text.trim();
    if (query.isEmpty || _isProcessing) return;

    setState(() {
      _messages.add(ChatMessage(
        content: query,
        isFromUser: true,
        timestamp: DateTime.now(),
      ));
      _isProcessing = true;
    });

    _controller.clear();

    try {
      // Get expense data for AI context
      final expenseData = _expenseService.getExpenseDataForAI();

      // Get AI insights
      final response = await _aiService.getInsights(query, expenseData);

      setState(() {
        _messages.add(ChatMessage(
          content: response,
          isFromUser: false,
          timestamp: DateTime.now(),
        ));
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          content: 'Sorry, I encountered an error: ${e.toString()}\n\nPlease try again or rephrase your question.',
          isFromUser: false,
          timestamp: DateTime.now(),
        ));
        _isProcessing = false;
      });
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: message.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isFromUser
                ? const Color(0xFFFFD60A)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: message.isFromUser ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: message.isFromUser ? Colors.black54 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String content;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isFromUser,
    required this.timestamp,
  });
}
