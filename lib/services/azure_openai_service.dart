import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class AzureOpenAIService {
  /// Parse natural language expense input with dynamic categories
  Future<Map<String, dynamic>> parseExpense(String input, {List<String>? availableCategories}) async {
    try {
      final prompt = _buildExpenseParsePrompt(input, availableCategories);
      final response = await _sendRequest(prompt);

      // Parse JSON response from AI
      final content = response['choices'][0]['message']['content'] as String;
      final cleanedJson = _cleanJsonResponse(content);
      return jsonDecode(cleanedJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing expense: $e');
      rethrow;
    }
  }

  /// Clean JSON response by removing markdown code blocks
  String _cleanJsonResponse(String response) {
    String cleaned = response.trim();

    // Remove markdown code blocks (```json or ``` at start/end)
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7); // Remove ```json
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3); // Remove ```
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3); // Remove trailing ```
    }

    return cleaned.trim();
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

  /// Build expense parsing prompt with dynamic categories
  String _buildExpenseParsePrompt(String input, List<String>? availableCategories) {
    final categories = availableCategories ?? [
      'Food & Dining',
      'Transportation',
      'Groceries',
      'Entertainment',
      'Shopping',
      'Healthcare',
      'Other'
    ];

    final categoryList = categories.map((cat) => '- $cat').join('\n');

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
$categoryList

Rules:
- Amount must be a positive number
- Category must be from the list above (match exactly)
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

  /// Generate AI spending summary
  Future<String> generateSpendingSummary(Map<String, dynamic> expenseData) async {
    try {
      final prompt = '''
You are a financial assistant. Provide a brief spending summary for the user.

Data:
${jsonEncode(expenseData)}

Generate a friendly 2-3 sentence summary covering:
1. Total spending and trend (up/down from last month)
2. Top spending category
3. One actionable insight or recommendation

Keep it under 100 words and conversational.
''';

      final response = await _sendRequest(prompt);
      final content = response['choices'][0]['message']['content'] as String;
      return content.trim();
    } catch (e) {
      print('Error generating summary: $e');
      return 'Unable to generate summary at this time.';
    }
  }

  /// Detect unusual spending patterns
  Future<List<String>> detectUnusualPatterns(Map<String, dynamic> expenseData) async {
    try {
      final prompt = '''
You are a financial analyst. Analyze spending patterns and identify unusual activity.

Data:
${jsonEncode(expenseData)}

Identify up to 3 unusual patterns such as:
- Unusually high spending in a category
- Sudden changes in spending habits
- Potential duplicate charges
- Missing regular expenses

Return ONLY a JSON array of strings (insights), each under 50 characters:
["insight 1", "insight 2", "insight 3"]

If no unusual patterns, return empty array: []
''';

      final response = await _sendRequest(prompt);
      final content = response['choices'][0]['message']['content'] as String;
      final cleanedJson = _cleanJsonResponse(content);
      final patterns = jsonDecode(cleanedJson) as List;
      return patterns.cast<String>();
    } catch (e) {
      print('Error detecting patterns: $e');
      return [];
    }
  }

  /// Predict next month spending
  Future<Map<String, dynamic>> predictNextMonthSpending(Map<String, dynamic> expenseData) async {
    try {
      final prompt = '''
You are a financial forecaster. Predict next month's spending based on historical data.

Data:
${jsonEncode(expenseData)}

Analyze trends and return ONLY valid JSON:
{
  "predictedTotal": <number>,
  "confidence": "<high/medium/low>",
  "reasoning": "<brief explanation under 50 chars>"
}
''';

      final response = await _sendRequest(prompt);
      final content = response['choices'][0]['message']['content'] as String;
      final cleanedJson = _cleanJsonResponse(content);
      return jsonDecode(cleanedJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error predicting spending: $e');
      return {
        'predictedTotal': 0.0,
        'confidence': 'low',
        'reasoning': 'Insufficient data for prediction',
      };
    }
  }

  /// Get personalized recommendations
  Future<List<String>> getPersonalizedRecommendations(Map<String, dynamic> expenseData) async {
    try {
      final prompt = '''
You are a financial advisor. Provide 3 personalized money-saving recommendations.

Data:
${jsonEncode(expenseData)}

Return ONLY a JSON array of 3 actionable recommendations:
["tip 1 (under 60 chars)", "tip 2 (under 60 chars)", "tip 3 (under 60 chars)"]

Focus on:
- Reducing highest spending categories
- Finding subscription savings
- Meal planning to reduce dining out
- Budget optimization
''';

      final response = await _sendRequest(prompt);
      final content = response['choices'][0]['message']['content'] as String;
      final cleanedJson = _cleanJsonResponse(content);
      final recommendations = jsonDecode(cleanedJson) as List;
      return recommendations.cast<String>();
    } catch (e) {
      print('Error getting recommendations: $e');
      return [
        'Track your daily spending',
        'Set category budgets',
        'Review subscriptions monthly',
      ];
    }
  }
}
