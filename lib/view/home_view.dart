import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200.h) {
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
          IconButton(
            icon: Icon(
              Get.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 24.r,
            ),
            onPressed: () {
              Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Obx(
              () => CustomSearchBar(
                initialValue: _viewModel.searchQuery.value,
                onChanged: (value) => _viewModel.searchProducts(value),
              ),
            ),
          ),
          
          // Products list
          Expanded(
            child: Obx(() {
              if (_viewModel.isLoading.value && _viewModel.products.isEmpty) {
                return const LoadingWidget();
              }

              if (_viewModel.errorMessage.value.isNotEmpty && _viewModel.products.isEmpty) {
                return AppErrorWidget(
                  errorMessage: _viewModel.errorMessage.value,
                  onRetry: () => _viewModel.fetchProducts(isRefresh: true),
                );
              }

              if (_viewModel.isEmpty.value) {
                return EmptyWidget(
                  onClearFilters: _viewModel.clearSearch,
                );
              }

              final productsCount = _viewModel.products.length;
              final hasMore = _viewModel.hasMore.value;

              return RefreshIndicator(
                onRefresh: () => _viewModel.fetchProducts(isRefresh: true),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: productsCount + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == productsCount) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      );
                    }

                    final product = _viewModel.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        // Navigate using GetX passing only product ID
                        Get.toNamed('/product/${product.id}');
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
