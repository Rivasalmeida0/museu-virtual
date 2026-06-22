import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/museum_piece.dart';
import '../providers/piece_providers.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/piece_card.dart';
import 'piece_detail_page.dart';

class GalleryPage extends ConsumerStatefulWidget {
  final int initialTab;

  const GalleryPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchBar(onChanged: (q) => setState(() => _searchQuery = q)),
        const SizedBox(height: 8),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Históricos'),
            Tab(text: 'Supercomputadores'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _PieceGrid(
                pieces: ref.watch(allPiecesProvider),
                searchQuery: _searchQuery,
                onTap: _openDetail,
              ),
              _PieceGrid(
                pieces: ref.watch(historicPiecesProvider),
                searchQuery: _searchQuery,
                onTap: _openDetail,
              ),
              _PieceGrid(
                pieces: ref.watch(supercomputerPiecesProvider),
                searchQuery: _searchQuery,
                onTap: _openDetail,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openDetail(MuseumPiece piece) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PieceDetailPage(piece: piece),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Pesquisar computadores...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _PieceGrid extends StatelessWidget {
  final AsyncValue<List<MuseumPiece>> pieces;
  final String searchQuery;
  final ValueChanged<MuseumPiece> onTap;

  const _PieceGrid({
    required this.pieces,
    required this.searchQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return pieces.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: LoadingGrid(),
      ),
      error: (err, stack) => ErrorDisplay(
        message: 'Erro ao carregar: ${err.toString().replaceAll("Exception: ", "")}',
        onRetry: () {},
      ),
      data: (list) {
        var filtered = list;
        if (searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          filtered = list.where((p) {
            return p.nome.toLowerCase().contains(q) ||
                p.fabricante.toLowerCase().contains(q) ||
                p.descricao.toLowerCase().contains(q);
          }).toList();
        }
        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              AppStrings.semDados,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return PieceCard(
                piece: filtered[index],
                onTap: () => onTap(filtered[index]),
              );
            },
          ),
        );
      },
    );
  }
}
