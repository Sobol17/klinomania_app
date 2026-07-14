import 'package:flutter/material.dart';

import '../../data/datasources/home_remote_data_source.dart';
import '../../domain/entities/home_summary.dart';

class HomeController extends ChangeNotifier {
  HomeController({this.remoteDataSource, this.useApi = true});

  final HomeRemoteDataSource? remoteDataSource;
  final bool useApi;

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
  HomeSummary? _summary;
  bool _isSummaryLoading = false;
  bool _hasLoadedSummary = false;
  String? _summaryError;

  List<String> get plans => _plans;
  String get activePlan => _activePlan;
  List<String> get cleaningTypes => _cleaningTypes;
  String get selectedCleaningType => _selectedCleaningType;
  int get currentNavigationIndex => _currentNavigationIndex;
  HomeSummary? get summary => _summary;
  bool get isSummaryLoading => _isSummaryLoading;
  String? get summaryError => _summaryError;

  void ensureSummaryLoaded() {
    if (_hasLoadedSummary || _isSummaryLoading || !useApi) return;
    _hasLoadedSummary = true;
    loadSummary();
  }

  Future<void> loadSummary() async {
    if (_isSummaryLoading || remoteDataSource == null) return;
    _isSummaryLoading = true;
    _summaryError = null;
    notifyListeners();
    try {
      _summary = await remoteDataSource!.fetchSummary();
    } catch (error) {
      _summaryError = error is StateError
          ? error.message
          : 'Что-то пошло не так. Попробуйте снова';
    } finally {
      _isSummaryLoading = false;
      notifyListeners();
    }
  }

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
