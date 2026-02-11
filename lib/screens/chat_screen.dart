import 'package:flutter/material.dart';
import '../services/azure_openai_service.dart';
import '../models/expense.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final AzureOpenAIService _aiService = AzureOpenAIService();
  bool _isProcessing = false;
  double _monthlyTotal = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI EXPENSE TRACKER',
          style: TextStyle(fontSize: 16, letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Monthly total
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'This Month\'s Total',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${_monthlyTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '5 transactions',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AI Assistant ready. Input expenses naturally:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '"spent \$25 on lunch at McDonald\'s with Sarah"',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            child: Row(
              children: [
                // Voice button
                IconButton(
                  onPressed: _startVoiceInput,
                  icon: const Icon(Icons.mic_none),
                  tooltip: 'Voice input',
                ),

                // Text field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter expense details...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (text) => _submitExpense(),
                  ),
                ),

                // Send button
                IconButton(
                  onPressed: _isProcessing ? null : _submitExpense,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          child: Text(
            message.content,
            style: TextStyle(
              color: message.isFromUser ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitExpense() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(content: text, isFromUser: true));
      _isProcessing = true;
    });

    _controller.clear();

    try {
      // Parse expense with AI
      final parsed = await _aiService.parseExpense(text);

      // Create expense
      final expense = Expense(
        id: const Uuid().v4(),
        userId: 'user123', // TODO: Get from auth
        amount: (parsed['amount'] as num).toDouble(),
        category: parsed['category'] as String,
        description: parsed['description'] as String,
        person: parsed['person'] as String?,
        date: parsed['date'] != null
            ? DateTime.parse(parsed['date'] as String)
            : DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Update monthly total
      setState(() {
        _monthlyTotal += expense.amount;
        _messages.add(
          ChatMessage(
            content: 'Added: ${expense.formattedAmount} - ${expense.description}',
            isFromUser: false,
          ),
        );
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            content: 'Sorry, I couldn\'t process that. Please try again.',
            isFromUser: false,
          ),
        );
        _isProcessing = false;
      });
    }
  }

  void _startVoiceInput() {
    // TODO: Implement voice input with speech_to_text
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice input coming soon!')),
    );
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

  ChatMessage({
    required this.content,
    required this.isFromUser,
  });
}
