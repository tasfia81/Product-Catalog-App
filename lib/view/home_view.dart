import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/widgets/empty_widget.dart';
import '../core/widgets/error_widget.dart';
import '../core/widgets/loading_widget.dart';
import '../viewmodel/product_viewmodel.dart';
import 'widgets/product_card.dart';
import 'widgets/search_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.didUpdateWidget(oldWidget);
    super.initState();
    // Load products on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().loadProducts();
    });
  }

  // Helper method to display sorting bottom sheet
  void _showSortBottomSheet(BuildContext context) {
    final viewModel = context.read<ProductViewModel>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.sort_rounded),
                title: const Text('Default'),
                trailing: viewModel.currentSortOption == SortOption.none
                    ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  viewModel.setSortOption(SortOption.none);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up_rounded),
                title: const Text('Price: Low to High'),
                trailing: viewModel.currentSortOption == SortOption.priceAsc
                    ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  viewModel.setSortOption(SortOption.priceAsc);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_down_rounded),
                title: const Text('Price: High to Low'),
                trailing: viewModel.currentSortOption == SortOption.priceDesc
                    ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  viewModel.setSortOption(SortOption.priceDesc);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_outline_rounded),
                title: const Text('Highest Rated'),
                trailing: viewModel.currentSortOption == SortOption.ratingDesc
                    ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  viewModel.setSortOption(SortOption.ratingDesc);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width > 600 ? 3 : 2;

    return Scaffold(
      body: SafeArea(
        child: Consumer<ProductViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const LoadingWidget();
            }

            if (viewModel.errorMessage.isNotEmpty) {
              return AppErrorWidget(
                errorMessage: viewModel.errorMessage,
                onRetry: viewModel.loadProducts,
              );
            }

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    floating: true,
                    expandedHeight: 180,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.08),
                              theme.colorScheme.surface,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome to',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      'Catalogify',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomSearchBar(
                                    initialValue: viewModel.searchQuery,
                                    onChanged: viewModel.setSearchQuery,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _showSortBottomSheet(context),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Column(
                children: [
                  // Category chips
                  if (viewModel.categories.isNotEmpty)
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: viewModel.categories.length,
                        itemBuilder: (context, index) {
                          final category = viewModel.categories[index];
                          final isSelected = viewModel.selectedCategory == category;
                          final text = category.isNotEmpty
                              ? category[0].toUpperCase() + category.substring(1)
                              : '';
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(text),
                              selected: isSelected,
                              onSelected: (_) => viewModel.setCategory(category),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              showCheckmark: false,
                              backgroundColor: theme.colorScheme.surface,
                              selectedColor: theme.colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Product Grid
                  Expanded(
                    child: viewModel.products.isEmpty
                        ? EmptyWidget(
                            onClearFilters: viewModel.clearFilters,
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: viewModel.products.length,
                            itemBuilder: (context, index) {
                              final product = viewModel.products[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  // Set selected product to avoid flickering
                                  viewModel.selectProduct(product);
                                  // Navigate
                                  Navigator.pushNamed(
                                    context,
                                    '/product-detail',
                                    arguments: product.id,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
