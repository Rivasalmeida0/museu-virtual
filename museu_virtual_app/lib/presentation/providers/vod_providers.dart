import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/vod_service.dart';

// ══════════════════════════════════════════════════════════════
//  FAVORITOS
// ══════════════════════════════════════════════════════════════

/// Estado dos favoritos do utilizador.
class FavoritosState {
  final List<Map<String, dynamic>> favoritos;
  final bool isLoading;
  final String? erro;

  const FavoritosState({
    this.favoritos = const [],
    this.isLoading = false,
    this.erro,
  });

  FavoritosState copyWith({
    List<Map<String, dynamic>>? favoritos,
    bool? isLoading,
    String? erro,
  }) {
    return FavoritosState(
      favoritos: favoritos ?? this.favoritos,
      isLoading: isLoading ?? this.isLoading,
      erro: erro,
    );
  }
}

class FavoritosNotifier extends StateNotifier<FavoritosState> {
  FavoritosNotifier() : super(const FavoritosState());

  Future<void> carregar() async {
    state = state.copyWith(isLoading: true, erro: null);
    try {
      final favoritos = await VodService.listarFavoritos();
      state = FavoritosState(favoritos: favoritos);
    } catch (e) {
      state = state.copyWith(isLoading: false, erro: e.toString());
    }
  }

  Future<void> toggleFavorito(int idConteudo) async {
    final isFav = await VodService.verificarFavorito(idConteudo);
    if (isFav) {
      await VodService.removerFavorito(idConteudo);
    } else {
      await VodService.adicionarFavorito(idConteudo);
    }
    await carregar();
  }

  Future<bool> isFavorito(int idConteudo) async {
    return VodService.verificarFavorito(idConteudo);
  }
}

final favoritosProvider =
    StateNotifierProvider<FavoritosNotifier, FavoritosState>((ref) {
  return FavoritosNotifier();
});

// ══════════════════════════════════════════════════════════════
//  HISTÓRICO
// ══════════════════════════════════════════════════════════════

class HistoricoState {
  final List<Map<String, dynamic>> itens;
  final bool isLoading;

  const HistoricoState({this.itens = const [], this.isLoading = false});
}

class HistoricoNotifier extends StateNotifier<HistoricoState> {
  HistoricoNotifier() : super(const HistoricoState());

  Future<void> carregar() async {
    state = const HistoricoState(isLoading: true);
    try {
      final itens = await VodService.listarHistorico();
      state = HistoricoState(itens: itens);
    } catch (e) {
      debugPrint('[HistoricoNotifier] Erro: $e');
      state = const HistoricoState();
    }
  }

  Future<void> registar(int idConteudo) async {
    await VodService.registarVisualizacao(idConteudo);
  }

  Future<void> limpar() async {
    await VodService.limparHistorico();
    state = const HistoricoState();
  }

  Future<void> removerItem(int id) async {
    await VodService.removerItemHistorico(id);
    await carregar();
  }
}

final historicoProvider =
    StateNotifierProvider<HistoricoNotifier, HistoricoState>((ref) {
  return HistoricoNotifier();
});

// ══════════════════════════════════════════════════════════════
//  CONTINUAR A ASSISTIR
// ══════════════════════════════════════════════════════════════

class ProgressoState {
  final List<Map<String, dynamic>> itens;
  final bool isLoading;

  const ProgressoState({this.itens = const [], this.isLoading = false});
}

class ProgressoNotifier extends StateNotifier<ProgressoState> {
  ProgressoNotifier() : super(const ProgressoState());

  Future<void> carregar() async {
    state = const ProgressoState(isLoading: true);
    try {
      final itens = await VodService.listarProgresso();
      state = ProgressoState(itens: itens);
    } catch (e) {
      debugPrint('[ProgressoNotifier] Erro: $e');
      state = const ProgressoState();
    }
  }

  Future<void> guardar({
    required int idConteudo,
    required int posicaoSegundos,
    required int duracaoTotalSegundos,
  }) async {
    await VodService.guardarProgresso(
      idConteudo: idConteudo,
      posicaoSegundos: posicaoSegundos,
      duracaoTotalSegundos: duracaoTotalSegundos,
    );
  }

  Future<Map<String, dynamic>?> obter(int idConteudo) async {
    return VodService.obterProgresso(idConteudo);
  }
}

final progressoProvider =
    StateNotifierProvider<ProgressoNotifier, ProgressoState>((ref) {
  return ProgressoNotifier();
});

// ══════════════════════════════════════════════════════════════
//  CATEGORIAS
// ══════════════════════════════════════════════════════════════

final categoriasProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return VodService.listarCategorias();
});

final conteudosPorCategoriaProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, idCategoria) async {
  return VodService.listarConteudosPorCategoria(idCategoria);
});
