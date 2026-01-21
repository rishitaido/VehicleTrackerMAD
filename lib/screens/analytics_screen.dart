import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../repos.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _vehiclesRepo = VehiclesRepo();
  final _maintenanceRepo = MaintenanceRepo();
  
  bool _isLoading = true;
  List<Vehicle> _vehicles = [];
  List<MaintenanceLog> _allLogs = [];
  
  // Chart data
  Map<ServiceType, double> _costByType = {};
  List<double> _monthlyCosts = List.filled(6, 0.0); // Last 6 months
  double _totalSpend = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _vehicles = await _vehiclesRepo.getAll();
      
      // Fetch logs for all vehicles
      var allLogs = <MaintenanceLog>[];
      for (var v in _vehicles) {
        if (v.id != null) {
          final logs = await _maintenanceRepo.getForVehicle(v.id!);
          allLogs.addAll(logs);
        }
      }
      _allLogs = allLogs;
      
      _processData();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _processData() {
    _costByType.clear();
    _totalSpend = 0.0;
    
    // Initialize monthly costs (0-5, where 5 is current month)
    _monthlyCosts = List.filled(6, 0.0);
    final now = DateTime.now();
    
    for (var log in _allLogs) {
      // Cost by Type
      _costByType[log.type] = (_costByType[log.type] ?? 0) + log.cost;
      _totalSpend += log.cost;
      
      // Monthly Costs (last 6 months)
      final difference = (now.year - log.date.year) * 12 + now.month - log.date.month;
      if (difference >= 0 && difference < 6) {
        // Map difference to index: 0 is 5 months ago, 5 is current month
        // difference 0 (current) -> index 5
        // difference 5 (5 months ago) -> index 0
        int index = 5 - difference;
        if (index >= 0 && index < 6) {
          _monthlyCosts[index] += log.cost;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Analytics'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _allLogs.isEmpty 
              ? const Center(child: Text('No maintenance data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(context),
                      const SizedBox(height: 24),
                      Text(
                        'Spending by Type',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: _buildPieChart(context),
                      ),
                      const SizedBox(height: 24),
                      _buildLegend(context),
                      const SizedBox(height: 32),
                      Text(
                        'Last 6 Months Spending',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: _buildBarChart(context),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Spending',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(symbol: '\$').format(_totalSpend),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: _costByType.entries.map((entry) {
          final isLarge = entry.value / _totalSpend > 0.15;
          return PieChartSectionData(
            color: _getServiceColor(entry.key),
            value: entry.value,
            title: '', // Percentages are now in the legend
            radius: isLarge ? 60 : 50,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _monthlyCosts.reduce((curr, next) => curr > next ? curr : next) * 1.2, // Add some headroom
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '\$${rod.toY.toStringAsFixed(0)}',
                TextStyle(color: Theme.of(context).colorScheme.onSurface),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < 6) {
                  final date = DateTime.now().subtract(Duration(days: 30 * (5 - index)));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat.MMM().format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: _monthlyCosts.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Theme.of(context).colorScheme.secondary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    if (_costByType.isEmpty) return const SizedBox();
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _costByType.entries.map((entry) {
        final percentage = (entry.value / _totalSpend * 100).toStringAsFixed(1);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getServiceColor(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key.label} ($percentage%)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getServiceColor(ServiceType type) {
    // Generate colors based on type hash or fixed map
    // Simple deterministic colors
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
    ];
    return colors[type.index % colors.length];
  }
}
