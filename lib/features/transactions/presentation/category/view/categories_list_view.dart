import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

class CategoriesListView extends StatefulWidget {
  const CategoriesListView({super.key});

  @override
  State<CategoriesListView> createState() => _CategoriesListViewState();
}

class _CategoriesListViewState extends State<CategoriesListView> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading || state is CategoriesInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is CategoriesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Не удалось загрузить категории',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CategoriesCubit>().loadCategories(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final categories = switch (state) {
            CategoriesLoaded s => s.categories,
            CategoryCreateSuccess s => s.categories,
            CategoryCreating s => s.previousCategories,
            CategoryCreateError s => s.previousCategories ?? const [],
            CategoriesEmpty _ => const <CategoryModel>[],
            _ => const <CategoryModel>[],
          };

          if (categories.isEmpty) {
            return Center(
              child: Text(
                'Категорий пока нет',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = categories[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (category.limitValue != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Лимит: ${category.limitValue}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CategoryCreateView(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
