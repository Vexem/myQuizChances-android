import 'dart:math' as math;
import '../models/test_record.dart';
import '../models/analysis_settings.dart';
import '../models/analysis_result.dart';

class AnalysisEngine {
  static const int passingErrorLimit = 3;

  /// Calculate Poisson Cumulative Distribution Function for errors <= 3
  static double poissonCdfAtLimit(double expectedErrors, {int limit = passingErrorLimit}) {
    if (expectedErrors <= 0.0) return 100.0;
    double probability = 0.0;
    for (int k = 0; k <= limit; k++) {
      probability += (math.exp(-expectedErrors) * math.pow(expectedErrors, k)) / _factorial(k);
    }
    return (probability * 100.0).clamp(0.0, 100.0);
  }

  static double _factorial(int n) {
    if (n <= 1) return 1.0;
    double res = 1.0;
    for (int i = 2; i <= n; i++) {
      res *= i;
    }
    return res;
  }

  /// Analyze the given records with user settings
  static AnalysisResult? analyze(List<TestRecord> records, AnalysisSettings settings) {
    if (records.isEmpty) return null;

    // 1. Sort records chronologically
    final sorted = List<TestRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 2. Take the most recent N records based on testCount setting
    final countToTake = math.min(settings.testCount, sorted.length);
    final recent = sorted.sublist(sorted.length - countToTake);

    if (recent.isEmpty) return null;

    final referenceDate = recent.last.date;
    final halfLifeDays = math.max(0.1, settings.halfLife);
    final decayRate = math.log(2) / halfLifeDays;

    double sumWeights = 0.0;
    final weights = <double>[];

    for (final r in recent) {
      final daysDiff = referenceDate.difference(r.date).inDays;
      final daysSince = math.max(0, daysDiff);
      final weight = math.exp(-decayRate * daysSince);
      weights.add(weight);
      sumWeights += weight;
    }

    if (sumWeights <= 0.0) sumWeights = 1.0;

    double weightedErrorsSum = 0.0;
    int passedCount = 0;
    final distribution = <int, int>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0};

    for (int i = 0; i < recent.length; i++) {
      final r = recent[i];
      final normWeight = weights[i] / sumWeights;
      weightedErrorsSum += r.errors * normWeight;

      if (r.errors <= passingErrorLimit) {
        passedCount++;
      }

      final bucket = math.min(r.errors, 4);
      distribution[bucket] = (distribution[bucket] ?? 0) + 1;
    }

    final expectedErrors = weightedErrorsSum;
    final historicalPct = (passedCount / recent.length) * 100.0;
    final baseProbability = poissonCdfAtLimit(expectedErrors);

    final stressFactor = math.max(1.0, settings.anxietyFactor);
    final stressExpectedErrors = expectedErrors * stressFactor;
    final stressProbability = poissonCdfAtLimit(stressExpectedErrors);

    return AnalysisResult(
      testsAnalyzed: recent.length,
      referenceDate: referenceDate,
      halfLife: halfLifeDays,
      expectedErrors: expectedErrors,
      passedTests: passedCount,
      historicalPercentage: historicalPct,
      predictedProbability: baseProbability,
      stressExpectedErrors: stressExpectedErrors,
      stressProbability: stressProbability,
      errorDistribution: distribution,
    );
  }
}
