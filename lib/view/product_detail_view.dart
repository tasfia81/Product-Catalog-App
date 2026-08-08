import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/widgets/error_widget.dart';
import '../core/widgets/loading_widget.dart';
import '../viewmodel/product_viewmodel.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final ProductViewModel _viewModel = Get.find<ProductViewModel>();
  String? _activeImageUrl;
  int? _lastProductId;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() {
    final idString = Get.parameters['id'];
    if (idString != null) {
      final id = int.tryParse(idString);
      if (id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _viewModel.getProductDetails(id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 24.r),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_viewModel.isLoadingDetail.value) {
          return const LoadingWidget(message: 'Fetching product details...');
        }

        if (_viewModel.detailErrorMessage.value.isNotEmpty) {
          return AppErrorWidget(
            errorMessage: _viewModel.detailErrorMessage.value,
            onRetry: _fetchDetails,
          );
        }

        final product = _viewModel.selectedProduct.value;
        if (product == null) {
          return const Center(child: Text('Product details not found'));
        }

        // Initialize/Sync active image when product changes
        if (_lastProductId != product.id) {
          _activeImageUrl = product.thumbnail;
          _lastProductId = product.id;
        }

        final discount = product.discountPercentage > 0;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Display Image
              Container(
                height: 300.h,
                width: double.infinity,
                color: Colors.white,
                child: Hero(
                  tag: 'product-image-${product.id}',
                  child: CachedNetworkImage(
                    imageUrl: _activeImageUrl ?? product.thumbnail,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(
                      Icons.broken_image_outlined,
                      size: 64.r,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand & Stock status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (product.brand != null)
                          Text(
                            product.brand!.toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 10
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            product.stock > 10
                                ? 'In Stock'
                                : 'Low Stock (${product.stock})',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: product.stock > 10
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Title
                    Text(
                      product.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Pricing
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        if (discount) ...[
                          SizedBox(width: 12.w),
                          Text(
                            '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Ratings & Category
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber[700],
                          size: 20.r,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          product.rating.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            product.category,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Description
                    Text(
                      'Description',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Image Gallery
                    if (product.images.isNotEmpty) ...[
                      Text(
                        'Product Images',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 70.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: product.images.length,
                          itemBuilder: (context, index) {
                            final imageUrl = product.images[index];
                            final isActive = imageUrl == _activeImageUrl;

                            return Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _activeImageUrl = imageUrl;
                                  });
                                },
                                child: Container(
                                  width: 70.w,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isActive
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outlineVariant,
                                      width: isActive ? 2.w : 1.w,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                    color: Colors.white,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
