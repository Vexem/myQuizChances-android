import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/test_record.dart';
import '../../models/analysis_settings.dart';
import '../../models/analysis_result.dart';
import '../../services/storage_service.dart';
import '../../services/analysis_engine.dart';
import '../../l10n/app_strings.dart';
import '../theme.dart';
import 'entry_screen.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;

  const HomeScreen({super.key, required this.storage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<TestRecord> _records;
  late AnalysisSettings _settings;
  AnalysisResult? _result;

  @override
  void initState() {
    super.initState();
    _records = widget.storage.loadRecords();
    _settings = widget.storage.loadSettings();
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _result = AnalysisEngine.analyze(_records, _settings);
    });
  }

  void _addRecord(TestRecord record) {
    setState(() {
      _records.add(record);
    });
    widget.storage.saveRecords(_records);
    _recalculate();
  }

  void _deleteRecord(String id) {
    setState(() {
      _records.removeWhere((r) => r.id == id);
    });
    widget.storage.saveRecords(_records);
    _recalculate();
  }

  void _clearAllRecords() {
    setState(() {
      _records.clear();
    });
    widget.storage.saveRecords(_records);
    _recalculate();
  }

  void _updateSettings(AnalysisSettings settings) {
    setState(() {
      _settings = settings;
    });
    widget.storage.saveSettings(_settings);
    _recalculate();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    final samples = [
      TestRecord(id: 's1', date: now.subtract(const Duration(days: 14)), errors: 5),
      TestRecord(id: 's2', date: now.subtract(const Duration(days: 13)), errors: 4),
      TestRecord(id: 's3', date: now.subtract(const Duration(days: 12)), errors: 4),
      TestRecord(id: 's4', date: now.subtract(const Duration(days: 10)), errors: 3),
      TestRecord(id: 's5', date: now.subtract(const Duration(days: 9)), errors: 2),
      TestRecord(id: 's6', date: now.subtract(const Duration(days: 8)), errors: 3),
      TestRecord(id: 's7', date: now.subtract(const Duration(days: 7)), errors: 2),
      TestRecord(id: 's8', date: now.subtract(const Duration(days: 6)), errors: 1),
      TestRecord(id: 's9', date: now.subtract(const Duration(days: 5)), errors: 2),
      TestRecord(id: 's10', date: now.subtract(const Duration(days: 4)), errors: 3),
      TestRecord(id: 's11', date: now.subtract(const Duration(days: 3)), errors: 1),
      TestRecord(id: 's12', date: now.subtract(const Duration(days: 2)), errors: 0),
      TestRecord(id: 's13', date: now.subtract(const Duration(days: 1)), errors: 2),
      TestRecord(id: 's14', date: now, errors: 1),
    ];
    setState(() {
      _records.addAll(samples);
    });
    widget.storage.saveRecords(_records);
    _recalculate();
  }

  void _exportJson() {
    final jsonStr = widget.storage.exportJson(_records);
    Clipboard.setData(ClipboardData(text: jsonStr));
  }

  @override
  Widget build(BuildContext context) {
    final lang = _settings.language;

    final pages = [
      EntryScreen(
        records: _records,
        language: lang,
        onAdd: _addRecord,
        onDelete: _deleteRecord,
        onClearAll: _clearAllRecords,
      ),
      AnalysisScreen(
        result: _result,
        settings: _settings,
        onUpdateSettings: _updateSettings,
      ),
      SettingsScreen(
        settings: _settings,
        onUpdateSettings: _updateSettings,
        onLoadSampleData: _loadSampleData,
        onExport: _exportJson,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_car, color: AppTheme.primaryCyan, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.t('app_title', lang),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  AppStrings.t('subtitle', lang),
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.edit_note_outlined),
            selectedIcon: const Icon(Icons.edit_note, color: AppTheme.primaryCyan),
            label: AppStrings.t('tab_entries', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics, color: AppTheme.primaryCyan),
            label: AppStrings.t('tab_analysis', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings, color: AppTheme.primaryCyan),
            label: AppStrings.t('tab_settings', lang),
          ),
        ],
      ),
    );
  }
}
