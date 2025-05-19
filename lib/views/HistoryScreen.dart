import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../models/health_entry.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryViewModel>(context, listen: false).loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _showDateRangePicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<HistoryViewModel>(context, listen: false).loadEntries(),
          ),
        ],
      ),
      body: Consumer<HistoryViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.entries.isEmpty) {
            return const Center(
              child: Text('No health entries found for selected period'),
            );
          }

          return Column(
            children: [
              _buildDateRangeHeader(context, viewModel),
              _buildSummaryCard(context, viewModel),
              Expanded(
                child: _buildEntryList(context, viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateRangeHeader(BuildContext context, HistoryViewModel viewModel) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateFormat.format(viewModel.startDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Icon(Icons.arrow_forward),
          Text(
            dateFormat.format(viewModel.endDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, HistoryViewModel viewModel) {
    final averages = viewModel.getAverageValues();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period Averages',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAverageItem(
                  context,
                  Icons.water_drop,
                  '${averages['waterIntake']} ml',
                  'Water',
                  Colors.blue,
                ),
                _buildAverageItem(
                  context,
                  Icons.bedtime,
                  '${averages['sleepHours'].toStringAsFixed(1)} hrs',
                  'Sleep',
                  Colors.indigo,
                ),
                _buildAverageItem(
                  context,
                  Icons.directions_walk,
                  '${averages['steps']}',
                  'Steps',
                  Colors.green,
                ),
                if (averages['weight'] > 0)
                  _buildAverageItem(
                    context,
                    Icons.monitor_weight,
                    '${averages['weight'].toStringAsFixed(1)} kg',
                    'Weight',
                    Colors.purple,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageItem(BuildContext context, IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEntryList(BuildContext context, HistoryViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.entries.length,
      itemBuilder: (context, index) {
        final entry = viewModel.entries[index];
        return _buildEntryCard(context, entry, viewModel);
      },
    );
  }

  Widget _buildEntryCard(BuildContext context, HealthEntry entry, HistoryViewModel viewModel) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(entry.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDeleteEntry(context, entry, viewModel),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8.0),
            Row(
              children: [
                _buildMetricItem(context, Icons.water_drop, '${entry.waterIntake} ml', Colors.blue),
                _buildMetricItem(context, Icons.bedtime, '${entry.sleepHours} hrs', Colors.indigo),
                _buildMetricItem(context, Icons.directions_walk, '${entry.steps}', Colors.green),
                _buildMetricItem(context, Icons.mood, entry.mood.emoji, entry.mood.color),
                if (entry.weight > 0)
                  _buildMetricItem(context, Icons.monitor_weight, '${entry.weight} kg', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, IconData icon, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
    
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: viewModel.startDate,
        end: viewModel.endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      viewModel.setDateRange(picked.start, picked.end);
    }
  }

  Future<void> _confirmDeleteEntry(BuildContext context, HealthEntry entry, HistoryViewModel viewModel) async {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete the entry for ${dateFormat.format(entry.date)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await viewModel.deleteEntry(entry.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entry for ${dateFormat.format(entry.date)} deleted'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}