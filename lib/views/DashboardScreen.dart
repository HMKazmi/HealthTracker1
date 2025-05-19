import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import 'widgets/summary_card.dart';
import 'HealthMetricsDisplay.dart';
import '../../models/health_entry.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Refresh data when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Health Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardViewModel>().refreshData(),
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final todayEntry = viewModel.todayEntry;
          if (todayEntry == null) {
            return const Center(child: Text('No data available for today'));
          }
          
          return RefreshIndicator(
            onRefresh: viewModel.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Health Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardSummary(context, todayEntry),
                  const SizedBox(height: 24),
                  Text(
                    'Weekly Trends',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklyTrends(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDashboardSummary(BuildContext context, HealthEntry entry) {
    final viewModel = Provider.of<DashboardViewModel>(context, listen: false);
    
    return Column(
      children: [
        // First row: Water and Sleep
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                icon: Icons.water_drop,
                title: 'Water',
                value: '${entry.waterIntake} ml',
                progress: viewModel.getWaterProgress(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                icon: Icons.bedtime,
                title: 'Sleep',
                value: '${entry.sleepHours} hrs',
                progress: viewModel.getSleepProgress(),
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second row: Steps and Mood
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                icon: Icons.directions_walk,
                title: 'Steps',
                value: '${entry.steps}',
                progress: viewModel.getStepsProgress(),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                icon: Icons.mood,
                title: 'Mood',
                value: entry.mood.emoji,
                progress: entry.mood.index / (MoodType.values.length - 1),
                color: entry.mood.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Third row: Weight
        if (entry.weight > 0)
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  icon: Icons.monitor_weight,
                  title: 'Weight',
                  value: '${entry.weight} kg',
                  progress: 1.0, // No specific progress for weight
                  color: Colors.purple,
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  Widget _buildWeeklyTrends(BuildContext context, DashboardViewModel viewModel) {
    return Column(
      children: [
        HealthMetricsDisplay(
          title: 'Water Intake (ml)',
          data: viewModel.getWaterChartData(),
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        HealthMetricsDisplay(
          title: 'Sleep Hours',
          data: viewModel.getSleepChartData(),
          color: Colors.indigo,
        ),
        const SizedBox(height: 16),
        HealthMetricsDisplay(
          title: 'Steps',
          data: viewModel.getStepsChartData(),
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        HealthMetricsDisplay(
          title: 'Weight (kg)',
          data: viewModel.getWeightChartData(),
          color: Colors.purple,
        ),
      ],
    );
  }
}