import 'package:flutter/material.dart';
import 'package:health_tracker/viewmodels/addentry_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/health_entry.dart';

class AddEntryView extends StatefulWidget {
  const AddEntryView({Key? key}) : super(key: key);

  @override
  State<AddEntryView> createState() => _AddEntryViewState();
}

class _AddEntryViewState extends State<AddEntryView> {
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _waterController = TextEditingController();
  final _sleepController = TextEditingController();
  final _stepsController = TextEditingController();
  final _weightController = TextEditingController();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeData();
  });
}

  Future<void> _initializeData() async {
    final viewModel = Provider.of<AddEntryViewModel>(context, listen: false);
    await viewModel.initialize(_selectedDate);
    _updateControllersFromEntry(viewModel.currentEntry);
  }

  void _updateControllersFromEntry(HealthEntry? entry) {
    if (entry == null) return;

    _waterController.text = entry.waterIntake > 0 ? entry.waterIntake.toString() : '';
    _sleepController.text = entry.sleepHours > 0 ? entry.sleepHours.toString() : '';
    _stepsController.text = entry.steps > 0 ? entry.steps.toString() : '';
    _weightController.text = entry.weight > 0 ? entry.weight.toString() : '';
  }

  @override
  void dispose() {
    _waterController.dispose();
    _sleepController.dispose();
    _stepsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Health Entry'),
        actions: [
          TextButton(
            onPressed: () => _saveEntry(context),
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AddEntryViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildForm(context, viewModel);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AddEntryViewModel viewModel) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(context, viewModel),
            const SizedBox(height: 24),
            _buildWaterIntakeField(viewModel),
            const SizedBox(height: 16),
            _buildSleepHoursField(viewModel),
            const SizedBox(height: 16),
            _buildStepsField(viewModel),
            const SizedBox(height: 16),
            _buildWeightField(viewModel),
            const SizedBox(height: 24),
            _buildMoodSelector(context, viewModel),
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
                onPressed: viewModel.isSaving ? null : () => _saveEntry(context),
                child: viewModel.isSaving
                    ? const CircularProgressIndicator()
                    : const Text('SAVE ENTRY'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, AddEntryViewModel viewModel) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    
    return InkWell(
      onTap: () => _selectDate(context, viewModel),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Text(
                  dateFormat.format(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntakeField(AddEntryViewModel viewModel) {
    return TextFormField(
      controller: _waterController,
      decoration: InputDecoration(
        labelText: 'Water Intake (ml)',
        hintText: 'Enter water intake in milliliters',
        prefixIcon: const Icon(Icons.water_drop, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final intake = int.tryParse(value);
          if (intake == null) {
            return 'Please enter a valid number';
          }
          if (intake < 0) {
            return 'Water intake cannot be negative';
          }
        }
        return null;
      },
      onChanged: (value) {
        final intake = int.tryParse(value) ?? 0;
        viewModel.updateWaterIntake(intake);
      },
    );
  }

  Widget _buildSleepHoursField(AddEntryViewModel viewModel) {
    return TextFormField(
      controller: _sleepController,
      decoration: InputDecoration(
        labelText: 'Sleep Hours',
        hintText: 'Enter hours of sleep',
        prefixIcon: const Icon(Icons.bedtime, color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final sleep = double.tryParse(value);
          if (sleep == null) {
            return 'Please enter a valid number';
          }
          if (sleep < 0) {
            return 'Sleep hours cannot be negative';
          }
          if (sleep > 24) {
            return 'Sleep hours cannot exceed 24';
          }
        }
        return null;
      },
      onChanged: (value) {
        final sleep = double.tryParse(value) ?? 0.0;
        viewModel.updateSleepHours(sleep);
      },
    );
  }

  Widget _buildStepsField(AddEntryViewModel viewModel) {
    return TextFormField(
      controller: _stepsController,
      decoration: InputDecoration(
        labelText: 'Steps',
        hintText: 'Enter number of steps',
        prefixIcon: const Icon(Icons.directions_walk, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final steps = int.tryParse(value);
          if (steps == null) {
            return 'Please enter a valid number';
          }
          if (steps < 0) {
            return 'Steps cannot be negative';
          }
        }
        return null;
      },
      onChanged: (value) {
        final steps = int.tryParse(value) ?? 0;
        viewModel.updateSteps(steps);
      },
    );
  }

  Widget _buildWeightField(AddEntryViewModel viewModel) {
    return TextFormField(
      controller: _weightController,
      decoration: InputDecoration(
        labelText: 'Weight (kg)',
        hintText: 'Enter your weight in kilograms',
        prefixIcon: const Icon(Icons.monitor_weight, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final weight = double.tryParse(value);
          if (weight == null) {
            return 'Please enter a valid number';
          }
          if (weight < 0) {
            return 'Weight cannot be negative';
          }
        }
        return null;
      },
      onChanged: (value) {
        final weight = double.tryParse(value) ?? 0.0;
        viewModel.updateWeight(weight);
      },
    );
  }

  Widget _buildMoodSelector(BuildContext context, AddEntryViewModel viewModel) {
    final currentMood = viewModel.currentEntry?.mood ?? MoodType.neutral;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: MoodType.values.map((mood) {
            final isSelected = mood == currentMood;
            
            return InkWell(
              onTap: () => viewModel.updateMood(mood),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? mood.color.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? mood.color : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mood.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mood.name.toUpperCase(),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? mood.color : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, AddEntryViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      await viewModel.initialize(_selectedDate);
      _updateControllersFromEntry(viewModel.currentEntry);
    }
  }

  Future<void> _saveEntry(BuildContext context) async {
    final viewModel = Provider.of<AddEntryViewModel>(context, listen: false);
    
    if (_formKey.currentState?.validate() ?? false) {
      final success = await viewModel.saveEntry();
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health entry saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Reset form for a new entry
        if (context.mounted) {
          setState(() {
            _selectedDate = DateTime.now();
          });
          await viewModel.initialize(_selectedDate);
          _updateControllersFromEntry(viewModel.currentEntry);
        }
      }
    }
  }
} 