import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/widgets/empty_widget.dart';
import '../core/widgets/error_widget.dart';
import '../core/widgets/loading_widget.dart';
import '../viewmodel/product_viewmodel.dart';
import 'widgets/product_grid_card.dart';
import 'widgets/search_bar.dart';
import 'widgets/filter_bottom_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ProductViewModel _viewModel = Get.find<ProductViewModel>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.h) {
      _viewModel.fetchProducts(isRefresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catalogify',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Filter Button with Reactive Active Count Badge
          Obx(() {
            final activeCount = _viewModel.activeFiltersCount;
            return IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.filter_alt_rounded, size: 24.r),
                  if (activeCount > 0)
                    Positioned(
                      right: -4.w,
                      top: -4.h,
                      child: Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14.w,
                          minHeight: 14.h,
                        ),
                        child: Center(
                          child: Text(
                            '$activeCount',
                            style: TextStyle(
                              color: theme.colorScheme.onError,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Get.bottomSheet(
                  const FilterBottomSheet(),
                  isScrollControlled: true,
                );
              },
            );
          }),
          IconButton(
            icon: Icon(
              Get.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              size: 24.r,
            ),
            onPressed: () {
              Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ///-------------------------------- Search section --------------------------------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Obx(
              () => CustomSearchBar(
                initialValue: _viewModel.searchQuery.value,
                onChanged: (value) => _viewModel.searchProducts(value),
              ),
            ),
          ),

          ///-------------------------------- Products Grid --------------------------------
          Expanded(
            child: Obx(() {
              if (_viewModel.isLoading.value && _viewModel.products.isEmpty) {
                return const LoadingWidget();
              }

              if (_viewModel.errorMessage.value.isNotEmpty &&
                  _viewModel.products.isEmpty) {
                return AppErrorWidget(
                  errorMessage: _viewModel.errorMessage.value,
                  onRetry: () => _viewModel.fetchProducts(isRefresh: true),
                );
              }

              if (_viewModel.isEmpty.value) {
                return EmptyWidget(onClearFilters: _viewModel.clearSearch);
              }

              // Special empty state when server products are available, but active filters excluded all of them
              if (_viewModel.products.isNotEmpty &&
                  _viewModel.filteredProducts.isEmpty) {
                return EmptyWidget(
                  title: 'No products match your filters',
                  message:
                      'Try adjusting or clearing your active filters to see results.',
                  icon: Icons.filter_list_off_rounded,
                  onClearFilters: _viewModel.clearFilters,
                );
              }

              final productsCount = _viewModel.filteredProducts.length;

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          _viewModel.fetchProducts(isRefresh: true),
                      child: GridView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180.w,
                          mainAxisSpacing: 8.h,
                          crossAxisSpacing: 8.w,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: productsCount,
                        itemBuilder: (context, index) {
                          final product = _viewModel.filteredProducts[index];
                          return ProductGridCard(
                            product: product,
                            onTap: () {
                              Get.toNamed('/product/${product.id}');
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  // Pagination spinner at the bottom of the screen (full width)
                  if (_viewModel.isLoadingMore.value)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
