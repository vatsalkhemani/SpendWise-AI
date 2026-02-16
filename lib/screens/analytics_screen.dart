import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/expense_service.dart';
import '../services/azure_openai_service.dart';
import '../models/expense.dart';
import '../utils/animations.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _aiService = AzureOpenAIService();
  String? _aiSummary;
  List<String>? _recommendations;
  bool _loadingInsights = false;

  void _loadAIInsights() async {
    final expenseService = ExpenseService();
    if (expenseService.expenses.isEmpty) return;

    setState(() {
      _loadingInsights = true;
    });

    try {
      final expenseData = expenseService.getExpenseDataForAI();
      final summary = await _aiService.generateSpendingSummary(expenseData);
      final recommendations = await _aiService.getPersonalizedRecommendations(expenseData);

      setState(() {
        _aiSummary = summary;
        _recommendations = recommendations;
        _loadingInsights = false;
      });
    } catch (e) {
      setState(() {
        _loadingInsights = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseService = ExpenseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Expense>>(
        stream: expenseService.expensesStream,
        builder: (context, snapshot) {
          final monthlyTrends = expenseService.getMonthlySpendingTrends(months: 6);
          final monthComparison = expenseService.getMonthComparison();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month comparison card
                SlideUpAnimation(
                  delay: const Duration(milliseconds: 0),
                  child: _buildMonthComparisonCard(monthComparison, context),
                ),

                const SizedBox(height: 24),

                // Spending trend chart
                SlideUpAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    '6-Month Spending Trend',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                if (monthlyTrends.isEmpty || monthlyTrends.values.every((v) => v == 0))
                  SlideUpAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: _buildEmptyState('No spending data yet', context),
                  )
                else
                  SlideUpAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildSpendingTrendChart(monthlyTrends),
                    ),
                  ),

                const SizedBox(height: 24),

                // Statistics cards
                SlideUpAnimation(
                  delay: const Duration(milliseconds: 300),
                  child: const Text(
                    'Quick Stats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                _buildQuickStatsGrid(expenseService, context),

                const SizedBox(height: 24),

                // AI Insights section
                SlideUpAnimation(
                  delay: const Duration(milliseconds: 550),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AI Insights',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (expenseService.expenses.isNotEmpty)
                        TextButton.icon(
                          onPressed: _loadingInsights ? null : _loadAIInsights,
                          icon: _loadingInsights
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome, size: 16),
                          label: Text(_loadingInsights ? 'Loading...' : 'Generate'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (_aiSummary != null) ...[
                  SlideUpAnimation(
                    delay: const Duration(milliseconds: 600),
                    child: _buildInsightCard(
                      'Spending Summary',
                      _aiSummary!,
                      Icons.description,
                      context,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (_recommendations != null && _recommendations!.isNotEmpty) ...[
                  SlideUpAnimation(
                    delay: const Duration(milliseconds: 650),
                    child: _buildRecommendationsCard(_recommendations!, context),
                  ),
                ] else if (_aiSummary == null && !_loadingInsights) ...[
                  SlideUpAnimation(
                    delay: const Duration(milliseconds: 600),
                    child: _buildEmptyInsightsState(context),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthComparisonCard(
    Map<String, double> comparison,
    BuildContext context,
  ) {
    final difference = comparison['difference'] ?? 0.0;
    final percentChange = comparison['percentChange'] ?? 0.0;
    final isIncrease = difference > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Month vs Last Month',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'This Month',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${comparison['thisMonth']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Last Month',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${comparison['lastMonth']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Change',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isIncrease ? Colors.red : Colors.green,
                        size: 16,
                      ),
                      Text(
                        '${percentChange.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isIncrease ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendChart(Map<String, double> monthlyTrends) {
    final entries = monthlyTrends.entries.toList();
    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value.toInt())}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  final monthLabel = entries[index].key.split('/')[0];
                  return Text(
                    monthLabel,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (entries.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: entries
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                .toList(),
            isCurved: true,
            color: const Color(0xFFFFD60A),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFFFD60A).withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(ExpenseService expenseService, BuildContext context) {
    final totalSpent = expenseService.getTotalSpent();
    final monthlyAverage = expenseService.getMonthlyAverage();
    final transactionCount = expenseService.expenses.length;
    final avgTransaction = transactionCount > 0 ? totalSpent / transactionCount : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SlideUpAnimation(
                delay: const Duration(milliseconds: 350),
                child: _buildStatCard(
                  'Total Spent',
                  '\$${totalSpent.toStringAsFixed(2)}',
                  Icons.payments,
                  context,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SlideUpAnimation(
                delay: const Duration(milliseconds: 400),
                child: _buildStatCard(
                  'Monthly Avg',
                  '\$${monthlyAverage.toStringAsFixed(2)}',
                  Icons.calendar_today,
                  context,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SlideUpAnimation(
                delay: const Duration(milliseconds: 450),
                child: _buildStatCard(
                  'Transactions',
                  '$transactionCount',
                  Icons.receipt_long,
                  context,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SlideUpAnimation(
                delay: const Duration(milliseconds: 500),
                child: _buildStatCard(
                  'Avg/Transaction',
                  '\$${avgTransaction.toStringAsFixed(2)}',
                  Icons.trending_up,
                  context,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFFFD60A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String content,
    IconData icon,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFFFD60A)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(List<String> recommendations, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, size: 20, color: Color(0xFFFFD60A)),
              SizedBox(width: 8),
              Text(
                'Money-Saving Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFFFFD60A))),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyInsightsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 12),
          const Text(
            'AI-Powered Insights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get personalized spending insights and recommendations powered by AI',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
