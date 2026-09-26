import 'package:flutter/material.dart';
import '../../models/analysis_settings.dart';
import '../../l10n/app_strings.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  final AnalysisSettings settings;
  final Function(AnalysisSettings) onUpdateSettings;
  final VoidCallback onLoadSampleData;
  final VoidCallback onExport;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onUpdateSettings,
    required this.onLoadSampleData,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final lang = settings.language;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.t('config_section', lang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Test count slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.t('tests_count_title', lang),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        '${settings.testCount}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.t('tests_count_help', lang),
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  Slider(
                    value: settings.testCount.toDouble(),
                    min: 5,
                    max: 150,
                    divisions: 29,
                    activeColor: AppTheme.primaryCyan,
                    onChanged: (val) {
                      onUpdateSettings(settings.copyWith(testCount: val.toInt()));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Half-life slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.t('half_life_title', lang),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        '${settings.halfLife.toStringAsFixed(1)} gg',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.t('half_life_help', lang),
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  Slider(
                    value: settings.halfLife,
                    min: 1.0,
                    max: 30.0,
                    divisions: 29,
                    activeColor: AppTheme.primaryCyan,
                    onChanged: (val) {
                      onUpdateSettings(settings.copyWith(halfLife: val));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Anxiety factor slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.t('anxiety_factor_title', lang),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        '${settings.anxietyFactor.toStringAsFixed(2)}x',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warningOrange, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.t('anxiety_factor_help', lang),
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  Slider(
                    value: settings.anxietyFactor,
                    min: 1.0,
                    max: 2.5,
                    divisions: 15,
                    activeColor: AppTheme.warningOrange,
                    onChanged: (val) {
                      onUpdateSettings(settings.copyWith(anxietyFactor: val));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // General settings
          const Text(
            'App Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                // Language
                ListTile(
                  leading: const Icon(Icons.language, color: AppTheme.primaryCyan),
                  title: Text(AppStrings.t('language_title', lang)),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'it', label: Text('IT')),
                      ButtonSegment(value: 'en', label: Text('EN')),
                    ],
                    selected: {settings.language},
                    onSelectionChanged: (set) {
                      if (set.isNotEmpty) {
                        onUpdateSettings(settings.copyWith(language: set.first));
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                // Theme
                SwitchListTile(
                  secondary: Icon(
                    settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppTheme.primaryCyan,
                  ),
                  title: Text(AppStrings.t('theme_title', lang)),
                  value: settings.isDarkMode,
                  onChanged: (val) {
                    onUpdateSettings(settings.copyWith(isDarkMode: val));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.auto_fix_high, color: AppTheme.passGreen),
                  title: Text(AppStrings.t('sample_data_title', lang)),
                  subtitle: Text(
                    AppStrings.t('sample_data_desc', lang),
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  onTap: onLoadSampleData,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download, color: AppTheme.primaryCyan),
                  title: Text(AppStrings.t('export_data', lang)),
                  onTap: () {
                    onExport();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.t('export_done', lang))),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
