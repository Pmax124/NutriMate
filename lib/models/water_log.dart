class WaterLog {
  final String date; // YYYY-MM-DD
  final int glasses; // mỗi ly = 250ml

  WaterLog({
    required this.date,
    required this.glasses,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'glasses': glasses,
      };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
        date: json['date'] ?? '',
        glasses: json['glasses'] ?? 0,
      );
}