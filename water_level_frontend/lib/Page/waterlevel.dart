import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // เพิ่มการนำเข้า Provider
import 'package:water_level_frontend/Page/chart.dart';
import 'package:water_level_frontend/Page/index.dart';
import '../provider/waterLevelProvider.dart';
import '../models/waterLevelModel.dart';

class WaterLevelPage extends StatefulWidget {
  @override
  _WaterLevelPageState createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  int currentIndex = 1; // ระบุว่าหน้าปัจจุบันคือ "ระดับน้ำ"
  final double tankHeight = 66.0; // ความสูงของถังน้ำ
  String selectedHour = "All"; // ค่าเริ่มต้นสำหรับเลือกชั่วโมง
  String selectedMonth = "All"; // ค่าเริ่มต้นสำหรับเลือกเดือน

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Level Data"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Consumer<WaterLevelProvider>(
        builder: (context, provider, child) {
          if (provider.waterLevels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.showAlert) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Alert: High Water Level"),
                  content: Text(
                    "The water level has reached a critical point: ${provider.waterLevels.last.level} cm!",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Close"),
                    ),
                  ],
                ),
              );
            });
          }

          final data = provider.waterLevels;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Dropdown สำหรับเลือกเดือนและชั่วโมง
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton<String>(
                      value: selectedMonth,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMonth = newValue!;
                        });
                      },
                      items: [
                        "All",
                        ...List.generate(12, (index) {
                          return DateFormat("MM")
                              .format(DateTime(2025, index + 1));
                        })
                      ].map<DropdownMenuItem<String>>((month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month == "All"
                              ? "All Months"
                              : "${month} ${getMonthName(month)}"),
                        );
                      }).toList(),
                    ),
                    DropdownButton<String>(
                      value: selectedHour,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedHour = newValue!;
                        });
                      },
                      items: [
                        "All",
                        ...List.generate(24, (index) => index.toString())
                      ].map<DropdownMenuItem<String>>((hour) {
                        return DropdownMenuItem<String>(
                          value: hour,
                          child: Text(hour == "All" ? "All Hours" : "$hour:00"),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                // แสดงข้อมูลในรายการ
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final waterLevel = data[index];
                      String formattedTimestamp =
                          "${waterLevel.date} ${waterLevel.time}";

                      // ฟิลเตอร์ข้อมูลตามเดือนและชั่วโมง
                      DateTime parsedTime =
                          DateFormat("HH:mm:ss").parse(waterLevel.time);
                      if ((selectedMonth == "All" ||
                              parsedTime.month.toString().padLeft(2, '0') ==
                                  selectedMonth) &&
                          (selectedHour == "All" ||
                              parsedTime.hour.toString() == selectedHour)) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            tileColor: getWaterLevelColor(waterLevel.level),
                            title: Text('ID: ${waterLevel.id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ระดับน้ำ: ${waterLevel.level} m'),
                                Text('ระยะห่าง: ${waterLevel.distance} m'),
                                Text('เวลา: $formattedTimestamp'),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container(); // ถ้าไม่ตรงเงื่อนไขไม่แสดงรายการ
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water),
            label: 'ระดับน้ำ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'กราฟ',
          ),
        ],
        onTap: (index) {
          if (index != currentIndex) {
            setState(() {
              currentIndex = index;
            });

            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => IndexPage()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WaterLevelPage()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChartPage()),
              );
            }
          }
        },
      ),
    );
  }

  String getMonthName(String month) {
    switch (month) {
      case '01':
        return 'มกราคม';
      case '02':
        return 'กุมภาพันธ์';
      case '03':
        return 'มีนาคม';
      case '04':
        return 'เมษายน';
      case '05':
        return 'พฤษภาคม';
      case '06':
        return 'มิถุนายน';
      case '07':
        return 'กรกฎาคม';
      case '08':
        return 'สิงหาคม';
      case '09':
        return 'กันยายน';
      case '10':
        return 'ตุลาคม';
      case '11':
        return 'พฤศจิกายน';
      case '12':
        return 'ธันวาคม';
      default:
        return '';
    }
  }

  // ฟังก์ชันกำหนดสีตามระดับน้ำ
  Color getWaterLevelColor(double level) {
    double percentage = (level / tankHeight) * 100;

    if (percentage <= 75) {
      return Colors.green;
    } else if (percentage <= 90) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
