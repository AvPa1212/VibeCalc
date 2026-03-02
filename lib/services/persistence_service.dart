import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static final PersistenceService _instance =
      PersistenceService._internal();

  factory PersistenceService() => _instance;

  PersistenceService._internal();

  SharedPreferences? _prefs;

  // Keys
  static const String _historyKey = "calc_history";
  static const String _graphHistoryKey = "graph_history";
  static const String _savedFunctionsKey = "saved_functions";
  static const String _themeKey = "selected_theme";
  static const String _degreeModeKey = "degree_mode";

  /// Initialize service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// ----------------------------
  /// Calculator History
  /// ----------------------------

  Future<void> saveHistory(List<String> history) async {
    await _prefs?.setStringList(_historyKey, history);
  }

  List<String> getHistory() {
    return _prefs?.getStringList(_historyKey) ?? [];
  }

  Future<void> addToHistory(String expression) async {
    List<String> history = getHistory();
    history.insert(0, expression);
    await saveHistory(history);
  }

  Future<void> clearHistory() async {
    await _prefs?.remove(_historyKey);
  }

  /// ----------------------------
  /// Graph History
  /// ----------------------------

  Future<void> saveGraphHistory(List<String> graphs) async {
    await _prefs?.setStringList(_graphHistoryKey, graphs);
  }

  List<String> getGraphHistory() {
    return _prefs?.getStringList(_graphHistoryKey) ?? [];
  }

  Future<void> addGraph(String function) async {
    List<String> graphs = getGraphHistory();
    graphs.insert(0, function);
    await saveGraphHistory(graphs);
  }

  /// ----------------------------
  /// Saved Functions
  /// ----------------------------

  Future<void> saveFunctions(List<String> functions) async {
    await _prefs?.setStringList(_savedFunctionsKey, functions);
  }

  List<String> getSavedFunctions() {
    return _prefs?.getStringList(_savedFunctionsKey) ?? [];
  }

  Future<void> addSavedFunction(String function) async {
    List<String> functions = getSavedFunctions();
    functions.insert(0, function);
    await saveFunctions(functions);
  }

  Future<void> removeSavedFunction(String function) async {
    List<String> functions = getSavedFunctions();
    functions.remove(function);
    await saveFunctions(functions);
  }

  /// ----------------------------
  /// Theme Persistence
  /// ----------------------------

  Future<void> setTheme(String themeName) async {
    await _prefs?.setString(_themeKey, themeName);
  }

  String getTheme() {
    return _prefs?.getString(_themeKey) ?? "VibeDark";
  }

  /// ----------------------------
  /// Degree / Radian Mode
  /// ----------------------------

  Future<void> setDegreeMode(bool isDegree) async {
    await _prefs?.setBool(_degreeModeKey, isDegree);
  }

  bool getDegreeMode() {
    return _prefs?.getBool(_degreeModeKey) ?? false;
  }

  /// ----------------------------
  /// Full Reset (Production Safe)
  /// ----------------------------

  Future<void> resetAll() async {
    await _prefs?.clear();
  }
}