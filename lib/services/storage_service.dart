import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_record.dart';
import '../models/analysis_settings.dart';

class StorageService {
  static const String _recordsKey = 'my_quiz_chances_records';
  static const String _settingsKey = 'my_quiz_chances_settings';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Records
  List<TestRecord> loadRecords() {
    final raw = _prefs.getString(_recordsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => TestRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveRecords(List<TestRecord> records) async {
    final encoded = json.encode(records.map((r) => r.toJson()).toList());
    return _prefs.setString(_recordsKey, encoded);
  }

  // Settings
  AnalysisSettings loadSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return const AnalysisSettings();
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return AnalysisSettings.fromJson(map);
    } catch (_) {
      return const AnalysisSettings();
    }
  }

  Future<bool> saveSettings(AnalysisSettings settings) async {
    final encoded = json.encode(settings.toJson());
    return _prefs.setString(_settingsKey, encoded);
  }

  // Import / Export JSON string
  String exportJson(List<TestRecord> records) {
    return json.encode(records.map((r) => r.toJson()).toList());
  }

  List<TestRecord> importJson(String jsonStr) {
    final list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => TestRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
