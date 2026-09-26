import 'package:flutter_test/flutter_test.dart';
import 'package:my_quiz_chances/models/test_record.dart';
import 'package:my_quiz_chances/models/analysis_settings.dart';
import 'package:my_quiz_chances/services/analysis_engine.dart';

void main() {
  group('AnalysisEngine', () {
    test('poissonCdfAtLimit calculates correctly for 0 errors', () {
      final p = AnalysisEngine.poissonCdfAtLimit(0.0);
      expect(p, 100.0);
    });

    test('poissonCdfAtLimit calculates correctly for standard lambda', () {
      // For lambda = 2.0, Poisson CDF(<=3) = exp(-2) * (1 + 2 + 4/2 + 8/6)
      // 1 + 2 + 2 + 1.3333 = 6.3333 -> 6.3333 * exp(-2) = ~0.8571 -> 85.71%
      final p = AnalysisEngine.poissonCdfAtLimit(2.0);
      expect(p, greaterThan(85.0));
      expect(p, lessThan(86.5));
    });

    test('analyze returns null for empty list', () {
      final result = AnalysisEngine.analyze([], const AnalysisSettings());
      expect(result, isNull);
    });

    test('analyze computes expected values with time decay', () {
      final now = DateTime.now();
      final records = [
        TestRecord(id: '1', date: now.subtract(const Duration(days: 10)), errors: 6),
        TestRecord(id: '2', date: now.subtract(const Duration(days: 2)), errors: 1),
        TestRecord(id: '3', date: now, errors: 0),
      ];
      final result = AnalysisEngine.analyze(records, const AnalysisSettings());
      expect(result, isNotNull);
      expect(result!.testsAnalyzed, 3);
      // Because recent tests have 0 and 1 mistakes, expected errors should be much lower than the simple mean (7/3 = 2.33)
      expect(result.expectedErrors, lessThan(2.0));
      expect(result.predictedProbability, greaterThan(85.0));
    });
  });
}
