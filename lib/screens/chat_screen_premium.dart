import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/azure_openai_service.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final AzureOpenAIService _aiService = AzureOpenAIService();
  final ExpenseService _expenseService = ExpenseService();
  bool _isProcessing = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceL,
        vertical: AppTheme.spaceM,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.yellowGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.buttonShadow,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI EXPENSE TRACKER',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                ),
                Text(
                  'Powered by GPT-4',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryYellow,
                      ),
                ),
              ],
            ),
          ),
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

        return AnimatedContainer(
          duration: AppTheme.durationNormal,
          padding: const EdgeInsets.all(AppTheme.spaceL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.cardBackground.withOpacity(0.5),
                AppTheme.darkBackground,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Text(
                'This Month',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: AppTheme.spaceS),
              TweenAnimationBuilder<double>(
                duration: AppTheme.durationSlow,
                tween: Tween(begin: 0, end: monthlyTotal),
                builder: (context, value, child) {
                  return Text(
                    '\$${value.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          foreground: Paint()
                            ..shader = AppTheme.yellowGradient.createShader(
                              const Rect.fromLTWH(0, 0, 200, 70),
                            ),
                        ),
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceXS),
              AnimatedSwitcher(
                duration: AppTheme.durationFast,
                child: Text(
                  '$transactionCount ${transactionCount == 1 ? 'expense' : 'expenses'}',
                  key: ValueKey(transactionCount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
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
        padding: const EdgeInsets.all(AppTheme.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceL),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: AppTheme.spaceL),
            Text(
              'Start Tracking',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spaceS),
            Text(
              'Just type naturally - I\'ll handle the rest',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceXL),
            _buildExampleChip('spent \$25 on lunch at McDonald\'s'),
            const SizedBox(height: AppTheme.spaceS),
            _buildExampleChip('\$67.32 groceries at Walmart'),
            const SizedBox(height: AppTheme.spaceS),
            _buildExampleChip('coffee with Mike \$18.75'),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceM,
        vertical: AppTheme.spaceS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.tertiaryCard,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppTheme.spaceM),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index], index);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.isFromUser;

    return TweenAnimationBuilder<double>(
      duration: AppTheme.durationNormal,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spaceM),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.yellowGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.black,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppTheme.spaceS),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceM,
                  vertical: AppTheme.spaceM,
                ),
                decoration: BoxDecoration(
                  gradient: isUser ? AppTheme.yellowGradient : null,
                  color: isUser ? null : AppTheme.cardBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppTheme.radiusLarge),
                    topRight: const Radius.circular(AppTheme.radiusLarge),
                    bottomLeft: Radius.circular(isUser ? AppTheme.radiusLarge : 4),
                    bottomRight: Radius.circular(isUser ? 4 : AppTheme.radiusLarge),
                  ),
                  boxShadow: isUser ? AppTheme.buttonShadow : AppTheme.cardShadow,
                ),
                child: Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isUser ? Colors.black : AppTheme.textPrimary,
                        fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Voice button
            _buildIconButton(
              icon: Icons.mic_rounded,
              onPressed: _startVoiceInput,
            ),
            const SizedBox(width: AppTheme.spaceS),
            // Text field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.secondaryCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: TextField(
                  controller: _controller,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Type your expense...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceM,
                      vertical: AppTheme.spaceM,
                    ),
                  ),
                  onSubmitted: (text) => _submitExpense(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spaceS),
            // Send button
            _buildIconButton(
              icon: _isProcessing ? Icons.hourglass_empty : Icons.arrow_upward_rounded,
              onPressed: _isProcessing ? null : _submitExpense,
              isPrimary: true,
              isLoading: _isProcessing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = false,
    bool isLoading = false,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: isPrimary ? AppTheme.yellowGradient : null,
        color: isPrimary ? null : AppTheme.secondaryCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: isPrimary ? AppTheme.buttonShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPrimary ? Colors.black : AppTheme.primaryYellow,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: isPrimary ? Colors.black : AppTheme.textPrimary,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitExpense() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      _messages.add(ChatMessage(content: text, isFromUser: true));
      _isProcessing = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // Parse expense with AI
      final parsed = await _aiService.parseExpense(text);

      // Create expense
      final expense = Expense(
        id: const Uuid().v4(),
        userId: 'user123',
        amount: (parsed['amount'] as num).toDouble(),
        category: parsed['category'] as String,
        description: parsed['description'] as String,
        person: parsed['person'] as String?,
        date: parsed['date'] != null
            ? DateTime.parse(parsed['date'] as String)
            : DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Save to expense service
      _expenseService.addExpense(expense);

      // Success haptic
      HapticFeedback.lightImpact();

      // Show confirmation
      setState(() {
        _messages.add(
          ChatMessage(
            content: '✓ Added ${expense.formattedAmount} for ${expense.description}\nCategory: ${expense.category}',
            isFromUser: false,
          ),
        );
        _isProcessing = false;
      });

      _scrollToBottom();
    } catch (e) {
      // Error haptic
      HapticFeedback.heavyImpact();

      setState(() {
        _messages.add(
          ChatMessage(
            content: 'Hmm, I couldn\'t understand that. Try something like:\n"spent \$25 on lunch"',
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
          duration: AppTheme.durationNormal,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _startVoiceInput() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Voice input coming soon!'),
        backgroundColor: AppTheme.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
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
