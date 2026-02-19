import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../services/azure_openai_service.dart';
import '../services/expense_service.dart';
import '../services/auth_service.dart';
import '../services/ocr_service.dart';
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
  final OcrService _ocrService = OcrService();
  bool _isProcessing = false;
  bool _isListening = false;
  bool _isCapturing = false;

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
            child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
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
            color: isUser ? const Color(0xFFFFD60A) : const Color(0xFF2C2C2E),
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
            // Camera button
            IconButton(
              onPressed:
                  _isProcessing || _isCapturing ? null : _startReceiptCapture,
              icon: const Icon(Icons.camera_alt),
              iconSize: 28,
              color: _isCapturing ? const Color(0xFFFFD60A) : Colors.white,
              tooltip: 'Scan receipt',
            ),
            // Voice button
            IconButton(
              onPressed: _isProcessing ? null : _startVoiceInput,
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
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
      final categoryNames =
          _expenseService.categories.map((c) => c.name).toList();
      final parsed = await _aiService.parseExpense(text,
          availableCategories: categoryNames);

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
            content:
                '✓ Added ${expense.formattedAmount} - ${expense.description}\nCategory: ${expense.category}',
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
            content:
                'Sorry, I couldn\'t process that. Try: "spent \$25 on lunch"',
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
          SnackBar(
              content: Text('Speech recognition error: ${error.errorMsg}')),
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

  /// Start receipt capture flow - show camera/gallery choice dialog
  Future<void> _startReceiptCapture() async {
    // Show source selector dialog
    final source = await _showImageSourceDialog();
    if (source == null) return;

    // Request permissions (skip on web)
    if (!kIsWeb) {
      final hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        _showPermissionError();
        return;
      }
    }

    // Capture/select image
    setState(() => _isCapturing = true);

    try {
      final image = await _ocrService.captureReceiptImage(source: source);
      setState(() => _isCapturing = false);

      if (image == null) return;

      // Process OCR
      await _processReceipt(image);
    } catch (e) {
      setState(() => _isCapturing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture image: $e')),
        );
      }
    }
  }

  /// Show dialog to choose camera or gallery
  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFFD60A)),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFFFFD60A)),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Request camera or photo library permission
  Future<bool> _requestPermission(ImageSource source) async {
    final permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;

    final status = await permission.request();
    return status.isGranted;
  }

  /// Show permission error with settings link
  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Permission required to access camera/photos'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => openAppSettings(),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Process receipt image: OCR → AI parsing → Review dialog
  Future<void> _processReceipt(XFile image) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFFFD60A)),
            SizedBox(height: 16),
            Text(
              'Reading receipt...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );

    try {
      // Step 1: Extract text via Azure Computer Vision
      final receiptText = await _ocrService.extractTextFromImage(image);

      // Step 2: Parse text into structured data via Azure OpenAI
      final categoryNames =
          _expenseService.categories.map((c) => c.name).toList();
      final parsed =
          await _aiService.parseReceiptText(receiptText, categoryNames);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Step 3: Show review dialog
      await _showReceiptReviewDialog(parsed);
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error
      _showErrorDialog('Could not read receipt', e.toString());
    }
  }

  /// Show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show receipt review dialog with editable fields
  Future<void> _showReceiptReviewDialog(
      Map<String, dynamic> extractedData) async {
    final amountController = TextEditingController(
      text: extractedData['amount']?.toString() ?? '',
    );
    final descController = TextEditingController(
      text: extractedData['description'] ?? '',
    );
    final personController = TextEditingController(
      text: extractedData['person'] ?? '',
    );

    String selectedCategory =
        extractedData['category'] ?? _expenseService.categories.first.name;
    DateTime selectedDate = extractedData['date'] != null
        ? DateTime.parse(extractedData['date'])
        : DateTime.now();

    return showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text('Review Receipt'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amount field
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixText: '\$',
                    prefixStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFD60A)),
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Description field
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFD60A)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Category dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  dropdownColor: const Color(0xFF2C2C2E),
                  items: _expenseService.categories
                      .map((c) => DropdownMenuItem(
                            value: c.name,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedCategory = val!),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFD60A)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Person field (optional)
                TextField(
                  controller: personController,
                  decoration: const InputDecoration(
                    labelText: 'Person (optional)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFD60A)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Date',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  subtitle: Text(
                    DateFormat.yMMMd().format(selectedDate),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  trailing: const Icon(Icons.calendar_today,
                      color: Color(0xFFFFD60A)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFFFFD60A),
                              surface: Color(0xFF2C2C2E),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate amount
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid amount')),
                  );
                  return;
                }

                // Create expense
                _createExpenseFromReceipt(
                  amount: amount,
                  description: descController.text.trim(),
                  category: selectedCategory,
                  person: personController.text.trim().isEmpty
                      ? null
                      : personController.text.trim(),
                  date: selectedDate,
                );

                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD60A),
                foregroundColor: Colors.black,
              ),
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  /// Create expense from receipt data (after user review)
  Future<void> _createExpenseFromReceipt({
    required double amount,
    required String description,
    required String category,
    String? person,
    required DateTime date,
  }) async {
    final expense = Expense(
      id: const Uuid().v4(),
      userId: AuthService().userId ?? 'anonymous',
      amount: amount,
      category: category,
      description: description,
      person: person,
      date: date,
      createdAt: DateTime.now(),
    );

    _expenseService.addExpense(expense);

    // Show success message
    HapticFeedback.mediumImpact();
    setState(() {
      _messages.add(ChatMessage(
        content: '✓ Added ${expense.formattedAmount} from receipt\n'
            '${expense.description}\n'
            'Category: $category',
        isFromUser: false,
      ));
    });

    _scrollToBottom();
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
