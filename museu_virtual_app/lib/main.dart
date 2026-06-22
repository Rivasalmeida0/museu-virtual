import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AngoTechMuseuApp(),
    ),
  );
}

class AngoTechMuseuApp extends StatelessWidget {
  const AngoTechMuseuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Museu Virtual de Computadores',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}
