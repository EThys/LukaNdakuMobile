import 'package:flutter/material.dart';
import 'package:luka_ndaku/screens/LoginPage.dart';
import 'package:luka_ndaku/screens/Splashscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'), // Français
      ],
      locale: const Locale('fr', 'FR'), // Forcer le français
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
