class WeightEntry {
  final String id;
  final double weight;
  final DateTime timestamp;

  WeightEntry({
    required this.id,
    required this.weight,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight': weight,
        'timestamp': timestamp.toIso8601String(),
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        id: json['id'] ?? '',
        weight: (json['weight'] ?? 0).toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
      );
}