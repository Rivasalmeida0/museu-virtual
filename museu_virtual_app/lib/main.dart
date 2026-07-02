import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_providers.dart';
import 'presentation/screens/home_page.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/gestor/painel_gestor_screen.dart';
import 'presentation/screens/admin/painel_admin_screen.dart';
import 'services/http_seguro_service.dart';

// Conditional import para o setup nativo (HttpOverrides, SecurityContext)
// Na web, importa um stub vazio que não usa dart:io.
import 'core/app_setup_nativo.dart'
    if (dart.library.html) 'core/app_setup_web.dart'
    as app_setup;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar overrides HTTP (apenas no nativo — na web é no-op)
  await app_setup.configurarPlataforma();

  await HttpSeguroService.inicializar();

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
              builder: (_) => const RotaProtegida(
                tela: PainelGestorScreen(),
                rolesPermitidos: ['gestor'],
              ),
            );
          case '/admin':
            return MaterialPageRoute(
              builder: (_) => const RotaProtegida(
                tela: PainelAdminScreen(),
                rolesPermitidos: ['admin'],
              ),
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

class RotaProtegida extends ConsumerWidget {
  final Widget tela;
  final List<String> rolesPermitidos;

  const RotaProtegida({
    required this.tela,
    required this.rolesPermitidos,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final roleActual = (authState.utilizador?['funcao'] as String? ?? '').toLowerCase().trim();

    debugPrint('[ROTA_PROTEGIDA] Role actual: "$roleActual" | Permitidos: $rolesPermitidos');

    if (rolesPermitidos.contains(roleActual)) {
      return tela;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/home');
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
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
    if (funcao == 'admin') {
      return const PainelAdminScreen();
    }
    if (funcao == 'gestor') {
      return const PainelGestorScreen();
    }

    return const HomePage();
  }
}
