import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/museum_piece_model.dart';
import '../../providers/vod_providers.dart';
import '../../widgets/piece_card.dart';
import '../piece_detail_page.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriasProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categorias', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Erro ao carregar categorias: $err',
            style: const TextStyle(color: AppColors.accentRed),
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('Nenhuma categoria disponível.'));
          }

          // Inicializar categoria selecionada se for nula
          if (_selectedCategoryId == null && categories.isNotEmpty) {
            _selectedCategoryId = categories[0]['id'] as int;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal scroll categories tabs
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat['id'] == _selectedCategoryId;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat['nome'] as String),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedCategoryId = cat['id'] as int);
                          }
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Content grid for selected category
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    if (_selectedCategoryId == null) {
                      return const SizedBox.shrink();
                    }

                    final contentAsync = ref.watch(
                      conteudosPorCategoriaProvider(_selectedCategoryId!),
                    );

                    return contentAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(
                        child: Text('Erro ao carregar vídeos: $err'),
                      ),
                      data: (items) {
                        if (items.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.movie_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Sem vídeos nesta categoria',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final piece = MuseumPieceModel.fromJson(item).toEntity();
                            
                            return PieceCard(
                              piece: piece,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PieceDetailPage(piece: piece),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
