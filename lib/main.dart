import 'package:flutter/material.dart';
import 'package:luka_ndaku/screens/LoginPage.dart';
import 'package:luka_ndaku/screens/Splashscreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
