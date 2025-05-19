import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentIndex = AppConstants.dashboardIndex;
  
  int get currentIndex => _currentIndex;
  
  void changeTab(int index) {
    if (index < 0 || index > 3) return; // Validate index
    
    _currentIndex = index;
    notifyListeners();
  }
}