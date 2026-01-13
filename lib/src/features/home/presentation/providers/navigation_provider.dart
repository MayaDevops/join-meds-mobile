import 'package:flutter/foundation.dart';

/// Provider for managing bottom navigation state
class NavigationProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;
  final Map<int, bool> _tabInitialized = {};

  /// Currently selected tab index
  int get selectedTabIndex => _selectedTabIndex;

  /// Check if a tab has been initialized
  bool isTabInitialized(int index) => _tabInitialized[index] ?? false;

  /// Set the selected tab index
  void setTab(int index) {
    if (index < 0 || index > 3) {
      debugPrint('NavigationProvider: Invalid tab index $index');
      return;
    }

    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      _tabInitialized[index] = true;
      notifyListeners();
    }
  }

  /// Reset to home tab
  void resetToHome() {
    if (_selectedTabIndex != 0) {
      _selectedTabIndex = 0;
      notifyListeners();
    }
  }

  /// Mark a tab as initialized
  void markTabInitialized(int index) {
    if (!_tabInitialized.containsKey(index)) {
      _tabInitialized[index] = true;
      notifyListeners();
    }
  }

  /// Reset all tab initialization states
  void resetTabStates() {
    _tabInitialized.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _tabInitialized.clear();
    super.dispose();
  }
}
