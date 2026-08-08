import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../model/product_model.dart';

enum SortOption {
  none,
  priceAsc,
  priceDesc,
  ratingDesc,
}

class ProductViewModel extends ChangeNotifier {
  final ApiService _apiService;

  ProductViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  // State variables for Product list
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // State variables for details
  Product? _selectedProduct;
  bool _isLoadingDetail = false;
  String _detailErrorMessage = '';

  // Active filters and settings
  String _selectedCategory = 'All';
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.none;

  // Getters
  List<Product> get products => _filteredProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Product? get selectedProduct => _selectedProduct;
  bool get isLoadingDetail => _isLoadingDetail;
  String get detailErrorMessage => _detailErrorMessage;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  SortOption get currentSortOption => _currentSortOption;

  /// Loads products and categories from the ApiService.
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final productsData = await _apiService.fetchProducts();
      _allProducts = productsData.map((json) => Product.fromJson(json)).toList();

      final categoriesData = await _apiService.fetchCategories();
      _categories = ['All', ...categoriesData];

      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads a single product detail from the ApiService.
  Future<void> loadProductDetail(int id) async {
    _isLoadingDetail = true;
    _detailErrorMessage = '';
    _selectedProduct = null;
    notifyListeners();

    try {
      final productData = await _apiService.fetchProductById(id);
      _selectedProduct = Product.fromJson(productData);
    } catch (e) {
      _detailErrorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Sets the selected product directly (for instant detail loading).
  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Sets the category filter and applies filters.
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the search query and applies filters.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the sorting option and applies filters.
  void setSortOption(SortOption option) {
    if (_currentSortOption == option) return;
    _currentSortOption = option;
    _applyFilters();
    notifyListeners();
  }

  /// Clears all active filters (search query, categories, sorting).
  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _currentSortOption = SortOption.none;
    _applyFilters();
    notifyListeners();
  }

  /// Internal helper to filter and sort the product list.
  void _applyFilters() {
    List<Product> results = List.from(_allProducts);

    // Apply category filtering
    if (_selectedCategory != 'All') {
      results = results.where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    // Apply search query filtering
    if (_searchQuery.isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase();
      results = results.where((p) {
        return p.title.toLowerCase().contains(lowercaseQuery) ||
               p.description.toLowerCase().contains(lowercaseQuery) ||
               p.category.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    // Apply sorting
    switch (_currentSortOption) {
      case SortOption.priceAsc:
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingDesc:
        results.sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
        break;
      case SortOption.none:
      default:
        // Keep default order from API
        break;
    }

    _filteredProducts = results;
  }
}
