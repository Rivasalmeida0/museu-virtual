import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_page.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/gestor/painel_gestor_screen.dart';

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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const HomePage(),
            );
          case '/gestor':
            return MaterialPageRoute(
              builder: (_) => const PainelGestorScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const HomePage(),
            );
        }
      },
    );
  }
}