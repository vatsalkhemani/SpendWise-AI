import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class AzureOpenAIService {
  /// Parse natural language expense input
  Future<Map<String, dynamic>> parseExpense(String input) async {
    try {
      final prompt = _buildExpenseParsePrompt(input);
      final response = await _sendRequest(prompt);

      // Parse JSON response from AI
      final content = response['choices'][0]['message']['content'] as String;
      return jsonDecode(content.trim()) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing expense: $e');
      rethrow;
    }
  }

  /// Categorize expense description
  Future<String> categorizeExpense(String description) async {
    try {
      final prompt = _buildCategorizationPrompt(description);
      final response = await _sendRequest(prompt);

      final content = response['choices'][0]['message']['content'] as String;
      return content.trim();
    } catch (e) {
      print('Error categorizing expense: $e');
      return 'Other'; // Fallback category
    }
  }

  /// Get AI insights about spending
  Future<String> getInsights(String query, Map<String, dynamic> expenseData) async {
    try {
      final prompt = _buildInsightsPrompt(query, expenseData);
      final response = await _sendRequest(prompt);

      final content = response['choices'][0]['message']['content'] as String;
      return content.trim();
    } catch (e) {
      print('Error getting insights: $e');
      rethrow;
    }
  }

  /// Stream chat response (for AI chat assistant)
  Stream<String> streamChatResponse(String query, Map<String, dynamic> context) async* {
    try {
      final prompt = _buildChatPrompt(query, context);
      // For now, return full response (streaming requires different API setup)
      final response = await _sendRequest(prompt);
      final content = response['choices'][0]['message']['content'] as String;

      // Simulate streaming by yielding chunks
      final words = content.split(' ');
      for (var word in words) {
        yield '$word ';
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      yield 'Sorry, I encountered an error. Please try again.';
    }
  }

  /// Send request to Azure OpenAI
  Future<Map<String, dynamic>> _sendRequest(String prompt) async {
    final url = Uri.parse(AzureOpenAIConfig.chatCompletionUrl);

    final body = jsonEncode({
      'messages': [
        {'role': 'system', 'content': 'You are a helpful financial assistant.'},
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.7,
      'max_tokens': 500,
    });

    final response = await http.post(
      url,
      headers: AzureOpenAIConfig.headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Azure OpenAI API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Build expense parsing prompt
  String _buildExpenseParsePrompt(String input) {
    return '''
You are an expense parser. Extract structured data from natural language input.

Input: "$input"

Extract and return ONLY valid JSON in this exact format:
{
  "amount": <number>,
  "category": "<category>",
  "description": "<brief description>",
  "person": "<person name or null>",
  "date": "<ISO date or null>"
}

Categories (choose ONLY from this list):
- Food & Dining
- Transportation
- Groceries
- Entertainment
- Shopping
- Healthcare
- Other

Rules:
- Amount must be a positive number
- Category must be from the list above
- Description should be brief (< 50 chars)
- Person is optional (null if not mentioned)
- Date is optional (null for today)
- Return ONLY the JSON, no other text
''';
  }

  /// Build categorization prompt
  String _buildCategorizationPrompt(String description) {
    return '''
Categorize this expense description into exactly ONE category.

Description: "$description"

Categories:
- Food & Dining: restaurants, cafes, food delivery
- Transportation: uber, lyft, gas, parking, transit
- Groceries: supermarkets, food shopping
- Entertainment: movies, concerts, streaming, games
- Shopping: clothing, electronics, general retail
- Healthcare: doctor, pharmacy, medical
- Other: anything else

Return ONLY the category name, nothing else.
''';
  }

  /// Build insights prompt
  String _buildInsightsPrompt(String query, Map<String, dynamic> expenseData) {
    return '''
You are a friendly financial assistant. Analyze the user's expenses and provide helpful insights.

Expense Data:
${jsonEncode(expenseData)}

User Question: "$query"

Provide a concise, helpful response (< 150 words). Be encouraging and actionable.
''';
  }

  /// Build chat prompt
  String _buildChatPrompt(String query, Map<String, dynamic> context) {
    return '''
You are a supportive financial assistant helping the user understand their spending.

Context:
${jsonEncode(context)}

User: "$query"

Respond naturally and helpfully. Keep it conversational and under 150 words.
''';
  }
}
