import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final Map<String, dynamic>? utilizador;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.utilizador,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? utilizador,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      utilizador: utilizador ?? this.utilizador,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> checkAuth() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      final user = await _authService.getUtilizadorAutenticado();
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          utilizador: user,
        );
        return;
      }
    }
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login(String email, String senha) async {
    state = state.copyWith(error: null);
    try {
      final result = await _authService.login(email, senha);
      state = AuthState(
        status: AuthStatus.authenticated,
        utilizador: result['utilizador'] as Map<String, dynamic>,
      );
    } on Exception catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> register(String nome, String email, String senha) async {
    state = state.copyWith(error: null);
    try {
      final result = await _authService.register(nome, email, senha);
      state = AuthState(
        status: AuthStatus.authenticated,
        utilizador: result['utilizador'] as Map<String, dynamic>,
      );
    } on Exception catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Erro ao registar: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
