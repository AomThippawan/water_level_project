import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/waterLevelModel.dart';

class WaterLevelController {
  final String apiUrl =
      "http://10.104.7.72:3030/api/waterlevels"; // ใช้ IP Address ของเครื่องคอมพิวเตอร์

  Future<List<WaterLevelModel>> fetchWaterLevels() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // แปลง response ที่เป็น List ของ JSON ไปเป็น List ของ WaterLevelModel
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => WaterLevelModel.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load water level data');
    }
  }
}
