import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/waterLevelProvider.dart';

import 'Page/index.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WaterLevelProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Level Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IndexPage(), // Start with Index Page
    );
  }
}
