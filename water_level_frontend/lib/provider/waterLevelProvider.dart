import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/waterLevelModel.dart';

class WaterLevelProvider extends ChangeNotifier {
  final String apiUrl = "http://10.0.2.2:3040/api/waterlevels"; // URL API
  List<WaterLevelModel> _waterLevels = [];
  bool _showAlert = false;

  List<WaterLevelModel> get waterLevels => _waterLevels;
  bool get showAlert => _showAlert;

  WaterLevelProvider() {
    _fetchDataPeriodically(); // เรียกดึงข้อมูลทุก ๆ 5 วินาที
  }

  // ดึงข้อมูลจาก API ทุก ๆ 5 วินาที
  void _fetchDataPeriodically() {
    fetchWaterLevels(); // ดึงข้อมูลครั้งแรก
    Future.delayed(Duration(seconds: 5), _fetchDataPeriodically);
  }

  // ฟังก์ชันดึงข้อมูลจาก MongoDB API
  Future<void> fetchWaterLevels() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        _waterLevels =
            jsonResponse.map((data) => WaterLevelModel.fromJson(data)).toList();

        print(
            "✅ Fetched water levels: ${_waterLevels.map((e) => e.level)}"); // Debug log
        _checkForAlert(); // ตรวจสอบระดับน้ำ
        notifyListeners(); // แจ้งให้ UI อัปเดต
      } else {
        throw Exception('Failed to load water level data');
      }
    } catch (e) {
      print("❌ Error fetching water levels: $e");
    }
  }

  // ฟังก์ชันตรวจสอบว่าควรแจ้งเตือนหรือไม่
  void _checkForAlert() {
    if (_waterLevels.isNotEmpty) {
      double latestLevel = _waterLevels.last.level;
      double threshold = 66 * 0.91; // 91% ของ 66 cm = 60.06 cm

      print("🔍 Checking Alert: Level = $latestLevel, Threshold = $threshold");

      if (latestLevel >= threshold) {
        print("🚨 ALERT TRIGGERED! Water Level = $latestLevel cm");
        _showAlert = true;
      } else {
        _showAlert = false;
      }

      notifyListeners(); // อัปเดต UI
    }
  }
}
