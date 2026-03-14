import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/checker/check_result.dart';
import 'history_entry.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _key = 'linksafe_history';

  Future<void> saveEntry(String url, CheckResult result) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(_key) ?? [];

    final newEntry = HistoryEntry(
      url: url,
      timestamp: DateTime.now(),
      riskLevel: result.riskLevel,
      reason: result.reason,
    );

    historyList.insert(0, jsonEncode(newEntry.toJson())); // Most recent first
    await prefs.setStringList(_key, historyList);
  }

  Future<List<HistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(_key) ?? [];

    return historyList.map((str) {
      return HistoryEntry.fromJson(jsonDecode(str));
    }).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
