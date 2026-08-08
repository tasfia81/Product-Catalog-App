import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../model/product_model.dart';

class ProductViewModel extends GetxController {
  final ApiService _apiService;

  ProductViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  // Observable states for Product List
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isEmpty = false.obs;

  // Pagination states
  final int _limit = 20;
  int _skip = 0;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;

  // Observable states for Product Detail
  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();
  final RxBool isLoadingDetail = false.obs;
  final RxString detailErrorMessage = ''.obs;

  // Active search query
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts(isRefresh: true);
  }

  /// Fetches products from DummyJSON with pagination support.
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
      final response = await _apiService.get(
        '/products',
        queryParameters: {
          'limit': _limit,
          'skip': _skip,
        },
      );

      final responseModel = ProductsResponseModel.fromJson(response.data as Map<String, dynamic>);
      
      if (isRefresh) {
        products.value = responseModel.products;
        isEmpty.value = products.isEmpty;
      } else {
        products.addAll(responseModel.products);
      }

      // Update skip offset for next request
      _skip += responseModel.products.length;

      // Check if we reached the end of the list
      if (products.length >= responseModel.total || responseModel.products.isEmpty) {
        hasMore.value = false;
      }
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

  /// Searches products by a text query.
  Future<void> searchProducts(String query) async {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      fetchProducts(isRefresh: true);
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    isEmpty.value = false;
    hasMore.value = false; // Turn off pagination for searches
    products.clear();

    try {
      final response = await _apiService.get(
        '/products/search',
        queryParameters: {
          'q': query.trim(),
        },
      );

      final responseModel = ProductsResponseModel.fromJson(response.data as Map<String, dynamic>);
      products.value = responseModel.products;
      isEmpty.value = products.isEmpty;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches a single product's details.
  Future<void> getProductDetails(int id) async {
    isLoadingDetail.value = true;
    detailErrorMessage.value = '';
    selectedProduct.value = null;

    try {
      final response = await _apiService.get('/products/$id');
      selectedProduct.value = ProductModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      detailErrorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Clear active search and reload all products.
  void clearSearch() {
    searchQuery.value = '';
    fetchProducts(isRefresh: true);
  }
}
