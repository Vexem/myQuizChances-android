class AnalysisResult {
  final int testsAnalyzed;
  final DateTime? referenceDate;
  final double halfLife;
  final double expectedErrors;
  final int passedTests;
  final double historicalPercentage;
  final double predictedProbability;
  final double stressExpectedErrors;
  final double stressProbability;
  final Map<int, int> errorDistribution; // keys 0, 1, 2, 3, 4 (4 means 4+)

  const AnalysisResult({
    required this.testsAnalyzed,
    required this.referenceDate,
    required this.halfLife,
    required this.expectedErrors,
    required this.passedTests,
    required this.historicalPercentage,
    required this.predictedProbability,
    required this.stressExpectedErrors,
    required this.stressProbability,
    required this.errorDistribution,
  });
}
