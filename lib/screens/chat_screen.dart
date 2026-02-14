import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/azure_openai_service.dart';
import '../services/expense_service.dart';
import '../services/auth_service.dart';
import '../models/expense.dart';
import '../utils/animations.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final AzureOpenAIService _aiService = AzureOpenAIService();
  final ExpenseService _expenseService = ExpenseService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isProcessing = false;
  bool _isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI EXPENSE TRACKER',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMonthlyTotal(),
          const Divider(height: 1),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMonthlyTotal() {
    return StreamBuilder<List<Expense>>(
      stream: _expenseService.expensesStream,
      builder: (context, snapshot) {
        final monthlyTotal = _expenseService.getMonthlyTotal();
        final transactionCount = _expenseService.getMonthlyTransactionCount();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              const Text(
                'This Month\'s Total',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${monthlyTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD60A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$transactionCount ${transactionCount == 1 ? 'transaction' : 'transactions'}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FadeInAnimation(
          duration: const Duration(milliseconds: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 24),
              const Text(
                'Start Tracking Your Expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Just type naturally - AI will handle the rest',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SlideUpAnimation(
                delay: const Duration(milliseconds: 300),
                child: _buildExampleChip('spent \$25 on lunch'),
              ),
              const SizedBox(height: 8),
              SlideUpAnimation(
                delay: const Duration(milliseconds: 400),
                child: _buildExampleChip('\$67.32 groceries at Walmart'),
              ),
              const SizedBox(height: 8),
              SlideUpAnimation(
                delay: const Duration(milliseconds: 500),
                child: _buildExampleChip('coffee with Mike \$18.75'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return SlideUpAnimation(
          delay: Duration(milliseconds: 50 * index),
          child: _buildMessageBubble(_messages[index]),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isFromUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser
                ? const Color(0xFFFFD60A)
                : const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: isUser ? Colors.black : Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        border: Border(
          top: BorderSide(color: Colors.grey[900]!),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Voice button
            IconButton(
              onPressed: _startVoiceInput,
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
              iconSize: 28,
              color: _isListening ? const Color(0xFFFFD60A) : Colors.white,
              tooltip: _isListening ? 'Stop listening' : 'Voice input',
            ),
            const SizedBox(width: 8),
            // Text field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Type your expense...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (text) => _submitExpense(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFD60A),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isProcessing ? null : _submitExpense,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.black),
                iconSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitExpense() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _messages.add(ChatMessage(content: text, isFromUser: true));
      _isProcessing = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // Get available categories for AI to use
      final categoryNames = _expenseService.categories.map((c) => c.name).toList();
      final parsed = await _aiService.parseExpense(text, availableCategories: categoryNames);

      final expense = Expense(
        id: const Uuid().v4(),
        userId: AuthService().userId ?? 'anonymous',
        amount: (parsed['amount'] as num).toDouble(),
        category: parsed['category'] as String,
        description: parsed['description'] as String,
        person: parsed['person'] as String?,
        date: parsed['date'] != null
            ? DateTime.parse(parsed['date'] as String)
            : DateTime.now(),
        createdAt: DateTime.now(),
      );

      _expenseService.addExpense(expense);

      HapticFeedback.lightImpact();

      setState(() {
        _messages.add(
          ChatMessage(
            content: '✓ Added ${expense.formattedAmount} - ${expense.description}\nCategory: ${expense.category}',
            isFromUser: false,
          ),
        );
        _isProcessing = false;
      });

      _scrollToBottom();
    } catch (e) {
      HapticFeedback.heavyImpact();

      setState(() {
        _messages.add(
          ChatMessage(
            content: 'Sorry, I couldn\'t process that. Try: "spent \$25 on lunch"',
            isFromUser: false,
          ),
        );
        _isProcessing = false;
      });

      _scrollToBottom();
    }
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

  Future<void> _startVoiceInput() async {
    if (_isListening) {
      // Stop listening
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    // Check if speech recognition is available
    bool available = await _speech.initialize(
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition error: ${error.errorMsg}')),
        );
      },
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
    );

    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available on this device'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
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
