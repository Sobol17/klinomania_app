import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  HomeController();

  static const int servicesTabIndex = 0;
  static const int historyTabIndex = 1;
  static const int profileTabIndex = 2;

  final List<String> _plans = const ['Экспресс', 'Стандарт', 'Премиум'];
  String _activePlan = 'Стандарт';

  final List<String> _cleaningTypes = const [
    'Генеральная',
    'После ремонта',
    'Мойка окон',
  ];
  String _selectedCleaningType = 'Мойка окон';

  int _currentNavigationIndex = servicesTabIndex;

  List<String> get plans => _plans;
  String get activePlan => _activePlan;
  List<String> get cleaningTypes => _cleaningTypes;
  String get selectedCleaningType => _selectedCleaningType;
  int get currentNavigationIndex => _currentNavigationIndex;

  void selectPlan(String value) {
    if (value == _activePlan || !_plans.contains(value)) {
      return;
    }
    _activePlan = value;
    notifyListeners();
  }

  void selectCleaningType(String value) {
    if (value == _selectedCleaningType || !_cleaningTypes.contains(value)) {
      return;
    }
    _selectedCleaningType = value;
    notifyListeners();
  }

  void selectNavigationIndex(int index) {
    if (index == _currentNavigationIndex) {
      return;
    }
    _currentNavigationIndex = index;
    notifyListeners();
  }
}
