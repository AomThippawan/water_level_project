import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:water_level_frontend/Page/index.dart';
import 'package:water_level_frontend/Page/waterlevel.dart';
import '../provider/waterLevelProvider.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final double tankHeight = 66.0;
  String selectedHour = "All";
  String selectedMonth = "All";

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
        title: Row(
          children: [
            Icon(Icons.show_chart,
                color: const Color.fromARGB(255, 239, 53, 53)),
            const SizedBox(width: 8),
            const Text(
              "Water Level Chart",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
                    parsedTime.month.toString().padLeft(2, '0') == selectedMonth) &&
                (selectedHour == "All" ||
                    parsedTime.hour.toString() == selectedHour)) {
              FlSpot spot = FlSpot(i.toDouble(), waterLevel);
              Color levelColor = getWaterLevelColor(waterLevel);
              if (levelColor == Colors.green) {
                greenSpots.add(spot);
              } else if (levelColor == Colors.yellow) {
                yellowSpots.add(spot);
              } else {
                redSpots.add(spot);
              }
              timeLabels.add(DateFormat("MM/dd HH:mm").format(parsedTime));
            }
          }

          return Column(
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
                          return DateFormat("MM")
                              .format(DateTime(2025, index + 1));
                        })
                      ].map<DropdownMenuItem<String>>((month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month == "All"
                              ? "All Months"
                              : "$month ${getMonthName(month)}"),
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
                child: Padding(
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
                              show: true, color: Colors.green.withOpacity(0.3)),
                        ),
                        LineChartBarData(
                          spots: yellowSpots,
                          isCurved: true,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          color: Colors.yellow,
                          belowBarData: BarAreaData(
                              show: true, color: Colors.yellow.withOpacity(0.3)),
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
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.blueAccent,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
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
            icon: Icon(Icons.bar_chart),
            label: 'กราฟ',
          ),
        ],
        onTap: (index) {
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
}
