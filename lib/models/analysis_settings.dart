class AnalysisSettings {
  final int testCount;
  final double halfLife;
  final String anxietyMode; // 'base' or 'stress'
  final double anxietyFactor;
  final String language; // 'it' or 'en'
  final bool isDarkMode;

  const AnalysisSettings({
    this.testCount = 50,
    this.halfLife = 7.0,
    this.anxietyMode = 'base',
    this.anxietyFactor = 1.2,
    this.language = 'it',
    this.isDarkMode = true,
  });

  bool get isStressMode => anxietyMode == 'stress';

  AnalysisSettings copyWith({
    int? testCount,
    double? halfLife,
    String? anxietyMode,
    double? anxietyFactor,
    String? language,
    bool? isDarkMode,
  }) {
    return AnalysisSettings(
      testCount: testCount ?? this.testCount,
      halfLife: halfLife ?? this.halfLife,
      anxietyMode: anxietyMode ?? this.anxietyMode,
      anxietyFactor: anxietyFactor ?? this.anxietyFactor,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'test_count': testCount,
        'half_life': halfLife,
        'anxiety_mode': anxietyMode,
        'anxiety_factor': anxietyFactor,
        'language': language,
        'is_dark_mode': isDarkMode,
      };

  factory AnalysisSettings.fromJson(Map<String, dynamic> json) {
    return AnalysisSettings(
      testCount: (json['test_count'] as num?)?.toInt() ?? 50,
      halfLife: (json['half_life'] as num?)?.toDouble() ?? 7.0,
      anxietyMode: json['anxiety_mode'] as String? ?? 'base',
      anxietyFactor: (json['anxiety_factor'] as num?)?.toDouble() ?? 1.2,
      language: json['language'] as String? ?? 'it',
      isDarkMode: json['is_dark_mode'] as bool? ?? true,
    );
  }
}
