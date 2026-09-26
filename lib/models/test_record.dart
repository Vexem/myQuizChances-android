class TestRecord {
  final String id;
  final DateTime date;
  final int errors;

  const TestRecord({
    required this.id,
    required this.date,
    required this.errors,
  });

  bool get isPassed => errors <= 3;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'errors': errors,
      };

  factory TestRecord.fromJson(Map<String, dynamic> json) {
    return TestRecord(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.parse(json['date'] as String),
      errors: (json['errors'] as num).toInt(),
    );
  }

  TestRecord copyWith({
    String? id,
    DateTime? date,
    int? errors,
  }) {
    return TestRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      errors: errors ?? this.errors,
    );
  }
}
