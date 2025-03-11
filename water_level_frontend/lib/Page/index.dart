import 'package:flutter/material.dart';
import 'waterlevel.dart';
import 'chart.dart';

class IndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1C60D2),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'ภาพรวม',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'สถานที่',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Column(
            children: const [
              Icon(Icons.water, size: 100, color: Colors.blueAccent),
              SizedBox(height: 8),
              Text(
                'WATER LEVEL',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'MONITORING AND ALERT SYSTEM',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueAccent,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WaterLevelPage()),
                      );
                    },
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.waterfall_chart,
                              color: Colors.white, size: 40),
                          SizedBox(height: 10),
                          Text('ระดับน้ำ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChartPage()),
                      );
                    },
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.cyan[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.timeline, color: Colors.white, size: 40),
                          SizedBox(height: 10),
                          Text(
                            'กราฟระดับน้ำ',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
}
