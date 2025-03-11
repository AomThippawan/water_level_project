import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/waterLevelProvider.dart';

class WaterLevelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Water Level Monitoring')),
      body: Consumer<WaterLevelProvider>(
        builder: (context, provider, child) {
          if (provider.waterLevels.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          double latestLevel = provider.waterLevels.last.level;

          // เช็คการแจ้งเตือนหลังจากโหลดข้อมูลแล้ว
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.showAlert) {
              print("🔔 Showing Alert: Level = $latestLevel"); // Debug log
              _showAlertDialog(context, latestLevel);
            } else {
              print("⚠️ No alert to show. Level = $latestLevel");
            }
          });

          return Center(
            child: Text(
              "Water Level: ${latestLevel.toStringAsFixed(2)} cm",
              style: TextStyle(fontSize: 24),
            ),
          );
        },
      ),
    );
  }

  void _showAlertDialog(BuildContext context, double level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("⚠️ Water Level Alert"),
        content: Text(
            "The water level has reached ${level.toStringAsFixed(2)} cm!\nPlease take action."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
