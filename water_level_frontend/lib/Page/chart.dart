import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // ใช้จัดรูปแบบเวลา
import '../controllers/waterLevelController.dart';
import '../models/waterLevelModel.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final WaterLevelController controller = WaterLevelController();
  late Future<List<WaterLevelModel>> futureWaterLevels;
  final double tankHeight = 66.0;
  String selectedHour = "All";
  String selectedMonth = "All";

  @override
  void initState() {
    super.initState();
    futureWaterLevels = controller.fetchWaterLevels();
  }

  Color getWaterLevelColor(double waterLevel) {
    double percentage = (waterLevel / tankHeight) * 100;
    if (percentage <= 75) return Colors.green;
    if (percentage <= 90) return Colors.yellow;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Level Chart"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
                      return DateFormat("MM").format(DateTime(2025, index + 1));
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
          ),
          Expanded(
            child: FutureBuilder<List<WaterLevelModel>>(
              future: futureWaterLevels,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  List<FlSpot> greenSpots = [];
                  List<FlSpot> yellowSpots = [];
                  List<FlSpot> redSpots = [];
                  List<String> timeLabels = [];

                  for (int i = 0; i < data.length; i++) {
                    double waterLevel = data[i].level.toDouble();
                    String rawTime = data[i].time;
                    DateTime parsedTime;
                    try {
                      if (rawTime.contains(".")) {
                        parsedTime = DateFormat("HH.mm.ss").parse(rawTime);
                      } else {
                        parsedTime = DateFormat("HH:mm:ss").parse(rawTime);
                      }
                    } catch (e) {
                      print("Error parsing time: $rawTime, error: $e");
                      parsedTime = DateTime.now();
                    }

                    if ((selectedMonth == "All" ||
                            parsedTime.month.toString().padLeft(2, '0') ==
                                selectedMonth) &&
                        (selectedHour == "All" ||
                            parsedTime.hour.toString() == selectedHour)) {
                      FlSpot spot = FlSpot(i.toDouble(), waterLevel);
                      if (getWaterLevelColor(waterLevel) == Colors.green) {
                        greenSpots.add(spot);
                      } else if (getWaterLevelColor(waterLevel) ==
                          Colors.yellow) {
                        yellowSpots.add(spot);
                      } else {
                        redSpots.add(spot);
                      }
                      timeLabels
                          .add(DateFormat("MM/dd HH:mm").format(parsedTime));
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text('Water Level (cm)',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 5,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toStringAsFixed(0),
                                    style: const TextStyle(fontSize: 12));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Text('Date & Time',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < timeLabels.length) {
                                  return Text(
                                    timeLabels[index],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                              interval: 1,
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: greenSpots,
                            isCurved: true,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.green,
                            belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green.withOpacity(0.3)),
                          ),
                          LineChartBarData(
                            spots: yellowSpots,
                            isCurved: true,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.yellow,
                            belowBarData: BarAreaData(
                                show: true,
                                color: Colors.yellow.withOpacity(0.3)),
                          ),
                          LineChartBarData(
                            spots: redSpots,
                            isCurved: true,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            color: Colors.red,
                            belowBarData: BarAreaData(
                                show: true, color: Colors.red.withOpacity(0.3)),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
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
}
