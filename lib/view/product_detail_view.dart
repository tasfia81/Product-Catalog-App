import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/widgets/error_widget.dart';
import '../core/widgets/loading_widget.dart';
import '../viewmodel/product_viewmodel.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  bool _isFavorite = false;
  int _quantity = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productId = ModalRoute.of(context)?.settings.arguments as int?;
    if (productId != null) {
      // Fetch details if not loaded or if we want a fresh update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = context.read<ProductViewModel>();
        if (viewModel.selectedProduct == null || viewModel.selectedProduct!.id != productId) {
          viewModel.loadProductDetail(productId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<ProductViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoadingDetail) {
              return const LoadingWidget(message: 'Loading details...');
            }

            if (viewModel.detailErrorMessage.isNotEmpty) {
              return AppErrorWidget(
                errorMessage: viewModel.detailErrorMessage,
                onRetry: () {
                  final productId = ModalRoute.of(context)?.settings.arguments as int?;
                  if (productId != null) {
                    viewModel.loadProductDetail(productId);
                  }
                },
              );
            }

            final product = viewModel.selectedProduct;
            if (product == null) {
              return const Center(child: Text('Product not found'));
            }

            final categoryText = product.category.isNotEmpty
                ? product.category[0].toUpperCase() + product.category.substring(1)
                : '';

            return Stack(
              children: [
                // Scrollable details
                CustomScrollView(
                  slivers: [
                    // Back button & Actions AppBar
                    SliverAppBar(
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
                            child: IconButton(
                              icon: Icon(
                                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: _isFavorite ? Colors.red : theme.colorScheme.onSurface,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                      expandedHeight: 300,
                      backgroundColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(32),
                          child: Hero(
                            tag: 'product-image-${product.id}',
                            child: Image.network(
                              product.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SliverList(
                      delegate: SliverChildListDelegate([
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    categoryText,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Title
                                Text(
                                  product.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Rating & Count
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.amber[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.star_rounded, size: 18, color: Colors.amber[800]),
                                          const SizedBox(width: 4),
                                          Text(
                                            product.rating.rate.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber[900],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${product.rating.count} Customer Reviews',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Divider
                                Divider(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                                const SizedBox(height: 16),

                                // Description Title
                                Text(
                                  'Description',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Description Content
                                Text(
                                  product.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Quantity selector
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Quantity',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: theme.colorScheme.outlineVariant),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_rounded),
                                            onPressed: _quantity > 1
                                                ? () => setState(() => _quantity--)
                                                : null,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              '$_quantity',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_rounded),
                                            onPressed: () => setState(() => _quantity++),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 100), // Spacing for bottom CTA
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),

                // Floating Bottom CTA bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Price',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '\$${(product.price * _quantity).toStringAsFixed(2)}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Successfully added $_quantity item(s) to Cart!'),
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
