import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/analysis_result.dart';
import '../../models/analysis_settings.dart';
import '../../l10n/app_strings.dart';
import '../widgets/probability_gauge.dart';
import '../widgets/error_chart.dart';
import '../theme.dart';

class AnalysisScreen extends StatelessWidget {
  final AnalysisResult? result;
  final AnalysisSettings settings;
  final Function(AnalysisSettings) onUpdateSettings;

  const AnalysisScreen({
    super.key,
    required this.result,
    required this.settings,
    required this.onUpdateSettings,
  });

  @override
  Widget build(BuildContext context) {
    final lang = settings.language;
    final r = result;

    if (r == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.analytics_outlined, size: 64, color: Colors.white.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                AppStrings.t('waiting_title', lang),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.t('waiting_desc', lang),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      );
    }

    final isStress = settings.isStressMode;
    final activeProb = isStress ? r.stressProbability : r.predictedProbability;
    final activeErrors = isStress ? r.stressExpectedErrors : r.expectedErrors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Anxiety Toggle Card
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: isStress ? AppTheme.warningOrange : AppTheme.primaryCyan,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.t('anxiety_mode', lang),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          AppStrings.t('anxiety_desc', lang),
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isStress,
                    activeThumbColor: AppTheme.warningOrange,
                    onChanged: (val) {
                      onUpdateSettings(settings.copyWith(
                        anxietyMode: val ? 'stress' : 'base',
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Big Probability Gauge
          ProbabilityGauge(
            probability: activeProb,
            isStress: isStress,
            language: lang,
          ),
          const SizedBox(height: 12),

          // Key Stats Grid
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: AppStrings.t('expected_errors', lang),
                  value: activeErrors.toStringAsFixed(2),
                  icon: Icons.functions,
                  color: activeErrors <= 3.0 ? AppTheme.passGreen : AppTheme.failRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  title: AppStrings.t('historical_pass', lang),
                  value: '${r.historicalPercentage.toStringAsFixed(1)}%',
                  icon: Icons.history,
                  color: AppTheme.primaryCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: AppStrings.t('analyzed_count', lang),
                  value: '${r.passedTests}/${r.testsAnalyzed}',
                  icon: Icons.checklist,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  title: AppStrings.t('reference_date', lang),
                  value: r.referenceDate != null ? DateFormat('dd/MM/yyyy').format(r.referenceDate!) : '-',
                  icon: Icons.calendar_today,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Error Distribution Bar Chart
          ErrorChart(
            distribution: r.errorDistribution,
            language: lang,
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
