import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_providers.dart';
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
      home: const AuthGate(),
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

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).checkAuth());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.status == AuthStatus.unknown) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.status == AuthStatus.unauthenticated) {
      return const LoginScreen();
    }

    final funcao = (authState.utilizador?['funcao'] as String? ?? '').toLowerCase();
    if (funcao == 'gestor' || funcao == 'admin') {
      return const PainelGestorScreen();
    }

    return const HomePage();
  }
}