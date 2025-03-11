class WaterLevelModel {
  final String id;
  final double level;
  final double distance;
  final String date; // เก็บเป็น YYYY-MM-DD
  final String time; // เก็บเป็น HH:MM:SS

  WaterLevelModel({
    required this.id,
    required this.level,
    required this.distance,
    required this.date,
    required this.time,
  });

  factory WaterLevelModel.fromJson(Map<String, dynamic> json) {
    return WaterLevelModel(
      id: json['_id'],
      level: json['level'].toDouble(),
      distance: json['distance'].toDouble(),
      date: json['date'], // รับค่า date จาก JSON
      time: json['time'], // รับค่า time จาก JSON
    );
  }
}
