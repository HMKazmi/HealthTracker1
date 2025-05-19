import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../viewmodels/home_viewmodel.dart';
import 'DashboardScreen.dart';
import 'HistoryScreen.dart';
import 'AddEntryScreen.dart';
import 'SettingsScreen.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          body: _getPage(viewModel.currentIndex),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: viewModel.currentIndex,
            onTap: viewModel.changeTab,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: 'Add Entry',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _getPage(int index) {
    switch (index) {
      case AppConstants.dashboardIndex:
        return const DashboardView();
      case AppConstants.historyIndex:
        return const HistoryView();
      case AppConstants.addEntryIndex:
        return const AddEntryView();
      case AppConstants.settingsIndex:
        return const SettingsView();
      default:
        return const DashboardView();
    }
  }
}