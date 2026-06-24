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
              builder: (_) => const AuthGate(),
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
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return switch (authState.status) {
      AuthStatus.unknown => const _SplashScreen(),
      AuthStatus.authenticated => _paginaPorRole(authState),
      AuthStatus.unauthenticated => const LoginScreen(),
    };
  }

  Widget _paginaPorRole(AuthState state) {
    final funcao = (state.utilizador?['funcao'] as String? ?? '').toLowerCase();
    if (funcao == 'gestor' || funcao == 'admin') {
      return const PainelGestorScreen();
    }
    return const HomePage();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0041C8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.computer,
                color: Color(0xFF0041C8),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Museu Virtual',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0041C8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
