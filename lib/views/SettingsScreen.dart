import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/settings_viewmodel.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveSettings(context),
          ),
        ],
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppearanceSection(context, viewModel),
                const Divider(height: 32),
                _buildUnitsSection(context, viewModel),
                const Divider(height: 32),
                _buildNotificationsSection(context, viewModel),
                const SizedBox(height: 32),
                if (viewModel.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      viewModel.errorMessage,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: viewModel.isSaving ? null : () => _saveSettings(context),
                    child: viewModel.isSaving
                        ? const CircularProgressIndicator()
                        : const Text('SAVE SETTINGS'),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAboutSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Appearance'),
        const SizedBox(height: 16),
        _buildThemeSelector(context, viewModel),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dark Theme'),
            Switch(
              value: viewModel.settings.isDarkMode,
              onChanged: (value) => viewModel.updateThemeMode(value),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsSection(BuildContext context, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Units'),
        const SizedBox(height: 16),
        _buildUnitSelector(
          context,
          'Weight Unit',
          viewModel.settings.weightUnit,
          ['kg', 'lbs'],
          (value) => viewModel.updateWeightUnit(value),
        ),
        const SizedBox(height: 16),
        _buildUnitSelector(
          context,
          'Water Unit',
          viewModel.settings.waterUnit,
          ['ml', 'cups'],
          (value) => viewModel.updateWaterUnit(value),
        ),
      ],
    );
  }

  Widget _buildUnitSelector(
    BuildContext context,
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            DropdownButton<String>(
              value: currentValue,
              onChanged: (value) => onChanged(value!),
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Notifications'),
        const SizedBox(height: 16),
        _buildNotificationToggle(context, viewModel),
        if (viewModel.settings.notificationsEnabled) ...[
          const SizedBox(height: 16),
          _buildReminderTimeSelector(context, viewModel),
        ],
      ],
    );
  }

  Widget _buildNotificationToggle(BuildContext context, SettingsViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Enable Daily Reminders'),
            Switch(
              value: viewModel.settings.notificationsEnabled,
              onChanged: (value) => viewModel.toggleNotifications(value),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTimeSelector(BuildContext context, SettingsViewModel viewModel) {
    final timeString = _formatTimeOfDay(viewModel.settings.reminderTime);
    
    return Card(
      child: InkWell(
        onTap: () => _selectReminderTime(context, viewModel),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reminder Time'),
              Row(
                children: [
                  Text(timeString),
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'About'),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Health Tracker',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Version 1.0.0'),
                const SizedBox(height: 16),
                const Text(
                  'Track your daily health metrics and build healthy habits with Daily Health Tracker.',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _showLicenses(context),
                      child: const Text('LICENSES'),
                    ),
                    TextButton(
                      onPressed: () => _showPrivacyPolicy(context),
                      child: const Text('PRIVACY POLICY'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectReminderTime(BuildContext context, SettingsViewModel viewModel) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: viewModel.settings.reminderTime,
    );
    
    if (picked != null && picked != viewModel.settings.reminderTime) {
      viewModel.updateReminderTime(picked);
    }
  }

  Future<void> _saveSettings(BuildContext context) async {
    final viewModel = Provider.of<SettingsViewModel>(context, listen: false);
    final success = await viewModel.saveSettings();
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Daily Health Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This app collects health data that you manually enter. '
            'Your data is stored locally on your device and is not shared with third parties. '
            'For more information or questions, please contact us at support@dailyhealthtracker.com.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}