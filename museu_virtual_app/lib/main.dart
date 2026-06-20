import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const AngoTechMuseuApp());
}

class AngoTechMuseuApp extends StatelessWidget {
  const AngoTechMuseuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AngoTech Museu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0041C8),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        fontFamily: 'Hanken Grotesk',
      ),
      home: const HomePage(),
    );
  }
}
