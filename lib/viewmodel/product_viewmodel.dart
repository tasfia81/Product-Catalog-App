import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../model/product_model.dart';

class ProductViewModel extends GetxController {
  final ApiService _apiService;

  ProductViewModel({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  ///-------------------------------- Observable states for Product List --------------------------------
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isEmpty = false.obs;

  ///-------------------------------- Pagination states --------------------------------
  final int _limit = 20;
  int _skip = 0;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;

  ///-------------------------------- Observable states for Product Detail --------------------------------
  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();
  final RxBool isLoadingDetail = false.obs;
  final RxString detailErrorMessage = ''.obs;

  ///-------------------------------- Active search query --------------------------------
  final RxString searchQuery = ''.obs;
  Timer? _searchDebounce;

  ///-------------------------------- Observable states for Product Filtering --------------------------------
  final RxList<String> categories = <String>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxnDouble minPrice = RxnDouble();
  final RxnDouble maxPrice = RxnDouble();
  final RxString minimumRating = 'All'.obs; // All, 4+, 3+, 2+
  final RxString selectedSort = 'Default'
      .obs; // Default, Price: Low to High, Price: High to Low, Rating: High to Low, Name: A to Z

  ///-------------------------------- Final filtered list displayed in GridView --------------------------------
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts(isRefresh: true);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  /// Fetches categories from DummyJSON category endpoint.
  Future<void> fetchCategories() async {
    try {
      final list = await _apiService.fetchCategories();
      categories.value = ['All', ...list];
    } catch (_) {
      // Fallback categories if API call fails
      categories.value = [
        'All',
        'beauty',
        'fragrances',
        'furniture',
        'groceries',
        'home-decoration',
        'laptops',
        'smartphones',
      ];
    }
  }

  /// Fetches products from DummyJSON with pagination support. Handles search query lists too.
  Future<void> fetchProducts({bool isRefresh = false}) async {
    // If already loading or loading more, do not trigger again
    if (isLoading.value || isLoadingMore.value) return;

    if (isRefresh) {
      _skip = 0;
      hasMore.value = true;
      isLoading.value = true;
      errorMessage.value = '';
      isEmpty.value = false;
      products.clear();
    } else {
      if (!hasMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final isSearch = searchQuery.value.trim().isNotEmpty;
      final path = isSearch ? '/products/search' : '/products';

      final queryParams = <String, dynamic>{'limit': _limit, 'skip': _skip};
      if (isSearch) {
        queryParams['q'] = searchQuery.value.trim();
      }

      final response = await _apiService.get(
        path,
        queryParameters: queryParams,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final responseModel = ProductsResponseModel.fromJson(data);

      if (isRefresh) {
        products.value = responseModel.products;
        isEmpty.value = products.isEmpty;
      } else {
        products.addAll(responseModel.products);
      }

      // Update skip offset for next request
      _skip += responseModel.products.length;

      // Check if we reached the end of the list
      if (products.length >= responseModel.total ||
          responseModel.products.isEmpty) {
        hasMore.value = false;
      }

      // Apply filters on the newly fetched products
      filterProducts();
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (isRefresh) {
        errorMessage.value = message;
      } else {
        Get.snackbar(
          'Error',
          'Failed to load more products: $message',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Filters and sorts products client-side based on active filter state.
  void filterProducts() {
    var tempProducts = List<ProductModel>.from(products);

    // Apply category filter
    if (selectedCategory.value != 'All') {
      tempProducts = tempProducts
          .where(
            (p) =>
                p.category.toLowerCase() ==
                selectedCategory.value.toLowerCase(),
          )
          .toList();
    }

    // Apply price filter
    if (minPrice.value != null) {
      tempProducts = tempProducts
          .where((p) => p.price >= minPrice.value!)
          .toList();
    }
    if (maxPrice.value != null) {
      tempProducts = tempProducts
          .where((p) => p.price <= maxPrice.value!)
          .toList();
    }

    // Apply rating filter
    if (minimumRating.value != 'All') {
      double minRate = 0.0;
      if (minimumRating.value == '4+') {
        minRate = 4.0;
      } else if (minimumRating.value == '3+') {
        minRate = 3.0;
      } else if (minimumRating.value == '2+') {
        minRate = 2.0;
      }
      tempProducts = tempProducts.where((p) => p.rating >= minRate).toList();
    }

    // Apply sorting
    if (selectedSort.value == 'Price: Low to High') {
      tempProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSort.value == 'Price: High to Low') {
      tempProducts.sort((a, b) => b.price.compareTo(a.price));
    } else if (selectedSort.value == 'Rating: High to Low') {
      tempProducts.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedSort.value == 'Name: A to Z') {
      tempProducts.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    }

    filteredProducts.value = tempProducts;
  }

  /// Sets category filter.
  void setCategory(String category) {
    selectedCategory.value = category;
    filterProducts();
  }

  /// Sets price range filter.
  void setPriceRange(double? min, double? max) {
    minPrice.value = min;
    maxPrice.value = max;
    filterProducts();
  }

  /// Sets minimum rating filter.
  void setMinimumRating(String rating) {
    minimumRating.value = rating;
    filterProducts();
  }

  /// Sets sorting option.
  void setSortOption(String sort) {
    selectedSort.value = sort;
    filterProducts();
  }

  /// Resets all active filters to default values (does not clear search query).
  void clearFilters() {
    selectedCategory.value = 'All';
    minPrice.value = null;
    maxPrice.value = null;
    minimumRating.value = 'All';
    selectedSort.value = 'Default';
    filterProducts();
  }

  /// Computes the number of active filters.
  int get activeFiltersCount {
    int count = 0;
    if (selectedCategory.value != 'All') count++;
    if (minPrice.value != null) count++;
    if (maxPrice.value != null) count++;
    if (minimumRating.value != 'All') count++;
    if (selectedSort.value != 'Default') count++;
    return count;
  }

  /// Searches products by a text query with debouncing and paginated results.
  void searchProducts(String query) {
    searchQuery.value = query;
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce!.cancel();
    }
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchProducts(isRefresh: true);
    });
  }

  /// Fetches a single product's details.
  Future<void> getProductDetails(int id) async {
    isLoadingDetail.value = true;
    detailErrorMessage.value = '';
    selectedProduct.value = null;

    try {
      final response = await _apiService.get('/products/$id');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      selectedProduct.value = ProductModel.fromJson(data);
    } catch (e) {
      detailErrorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Clear active search, clear all filters, and reload all products.
  void clearSearch() {
    searchQuery.value = '';
    clearFilters();
    fetchProducts(isRefresh: true);
  }
}
