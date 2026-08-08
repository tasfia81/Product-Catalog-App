import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:product_catalog_app/core/services/api_service.dart';
import 'package:product_catalog_app/model/product_model.dart';
import 'package:product_catalog_app/viewmodel/product_viewmodel.dart';

void main() {
  group('ProductModel Tests', () {
    final validJson = {
      'id': 1,
      'title': 'iPhone 9',
      'description': 'An apple mobile which is nothing like apple',
      'category': 'smartphones',
      'price': 549.0,
      'discountPercentage': 12.96,
      'rating': 4.69,
      'stock': 94,
      'brand': 'Apple',
      'thumbnail': 'https://dummyjson.com/image/i/products/1/thumbnail.jpg',
      'images': [
        'https://dummyjson.com/image/i/products/1/1.jpg',
        'https://dummyjson.com/image/i/products/1/2.jpg',
      ],
    };

    test('fromJson parses valid JSON correctly', () {
      final product = ProductModel.fromJson(validJson);
      expect(product.id, 1);
      expect(product.title, 'iPhone 9');
      expect(
        product.description,
        'An apple mobile which is nothing like apple',
      );
      expect(product.category, 'smartphones');
      expect(product.price, 549.0);
      expect(product.discountPercentage, 12.96);
      expect(product.rating, 4.69);
      expect(product.stock, 94);
      expect(product.brand, 'Apple');
      expect(
        product.thumbnail,
        'https://dummyjson.com/image/i/products/1/thumbnail.jpg',
      );
      expect(product.images, [
        'https://dummyjson.com/image/i/products/1/1.jpg',
        'https://dummyjson.com/image/i/products/1/2.jpg',
      ]);
    });

    test('fromJson handles missing or nullable fields gracefully', () {
      final jsonWithNulls = {
        'id': 2,
        'title': 'Test product',
        'price': null,
        'brand': null,
        'images': null,
      };

      final product = ProductModel.fromJson(jsonWithNulls);
      expect(product.id, 2);
      expect(product.title, 'Test product');
      expect(product.description, '');
      expect(product.category, '');
      expect(product.price, 0.0);
      expect(product.discountPercentage, 0.0);
      expect(product.rating, 0.0);
      expect(product.stock, 0);
      expect(product.brand, isNull);
      expect(product.thumbnail, '');
      expect(product.images, isEmpty);
    });

    test('toJson returns expected Map', () {
      final product = ProductModel.fromJson(validJson);
      final jsonOutput = product.toJson();
      expect(jsonOutput['id'], 1);
      expect(jsonOutput['title'], 'iPhone 9');
      expect(jsonOutput['brand'], 'Apple');
      expect(jsonOutput['images'], isList);
    });

    test('ProductsResponseModel.fromJson parses response list correctly', () {
      final responseJson = {
        'products': [validJson],
        'total': 100,
        'skip': 10,
        'limit': 5,
      };

      final response = ProductsResponseModel.fromJson(responseJson);
      expect(response.total, 100);
      expect(response.skip, 10);
      expect(response.limit, 5);
      expect(response.products, hasLength(1));
      expect(response.products[0].title, 'iPhone 9');

      final backToJson = response.toJson();
      expect(backToJson['total'], 100);
      expect(backToJson['products'], isList);
    });
  });

  group('ApiService Tests', () {
    test('get returns successful response', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });
      final apiService = ApiService(client: client);

      final response = await apiService.get('/test');
      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['success'], true);
    });

    test('fetchCategories returns list of categories', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(['beauty', 'fragrances', 'furniture']),
          200,
        );
      });
      final apiService = ApiService(client: client);

      final categories = await apiService.fetchCategories();
      expect(categories, ['beauty', 'fragrances', 'furniture']);
    });

    test('get throws Exception on server error (404, 500)', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Resource not found'}),
          404,
        );
      });
      final apiService = ApiService(client: client);

      expect(
        () => apiService.get('/invalid'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Server error (404): Resource not found'),
          ),
        ),
      );
    });
  });

  group('ProductViewModel Tests', () {
    late ApiService mockApiService;
    late ProductViewModel viewModel;
    late Map<String, dynamic> fakeProductsResponse;

    setUp(() {
      fakeProductsResponse = {
        'products': [
          {
            'id': 1,
            'title': 'Test Smartphone X',
            'description': 'A smartphone',
            'category': 'smartphones',
            'price': 499.0,
            'discountPercentage': 10.0,
            'rating': 4.5,
            'stock': 15,
            'brand': 'BrandX',
            'thumbnail': 'https://example.com/thumb.jpg',
            'images': ['https://example.com/img.jpg'],
          },
          {
            'id': 2,
            'title': 'Cheap Laptop',
            'description': 'A laptop',
            'category': 'laptops',
            'price': 899.0,
            'discountPercentage': 5.0,
            'rating': 3.8,
            'stock': 5,
            'brand': 'BrandY',
            'thumbnail': 'https://example.com/thumb2.jpg',
            'images': ['https://example.com/img2.jpg'],
          },
          {
            'id': 3,
            'title': 'High-end Laptop',
            'description': 'A premium laptop',
            'category': 'laptops',
            'price': 1599.0,
            'discountPercentage': 15.0,
            'rating': 4.9,
            'stock': 2,
            'brand': 'BrandZ',
            'thumbnail': 'https://example.com/thumb3.jpg',
            'images': ['https://example.com/img3.jpg'],
          },
        ],
        'total': 3,
        'skip': 0,
        'limit': 20,
      };
    });

    test('Initial State is correct', () {
      final client = MockClient((request) async => http.Response('', 200));
      mockApiService = ApiService(client: client);
      viewModel = ProductViewModel(apiService: mockApiService);

      expect(viewModel.products, isEmpty);
      expect(viewModel.filteredProducts, isEmpty);
      expect(viewModel.selectedCategory.value, 'All');
      expect(viewModel.minPrice.value, isNull);
      expect(viewModel.maxPrice.value, isNull);
      expect(viewModel.minimumRating.value, 'All');
      expect(viewModel.selectedSort.value, 'Default');
      expect(viewModel.activeFiltersCount, 0);
    });

    test('fetchCategories loads categories from API', () async {
      final client = MockClient((request) async {
        if (request.url.path.contains('category-list')) {
          return http.Response(jsonEncode(['smartphones', 'laptops']), 200);
        }
        return http.Response(jsonEncode(fakeProductsResponse), 200);
      });
      mockApiService = ApiService(client: client);
      viewModel = ProductViewModel(apiService: mockApiService);

      await viewModel.fetchCategories();
      expect(viewModel.categories, ['All', 'smartphones', 'laptops']);
    });

    test('Filtering by category returns only category items', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(fakeProductsResponse), 200);
      });
      mockApiService = ApiService(client: client);
      viewModel = ProductViewModel(apiService: mockApiService);

      await viewModel.fetchProducts(isRefresh: true);

      expect(viewModel.products, hasLength(3));
      expect(viewModel.filteredProducts, hasLength(3));

      // Filter by laptops
      viewModel.setCategory('laptops');
      expect(viewModel.filteredProducts, hasLength(2));
      expect(
        viewModel.filteredProducts.every((p) => p.category == 'laptops'),
        isTrue,
      );
      expect(viewModel.activeFiltersCount, 1);
    });

    test('Filtering by price range applies limits correctly', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(fakeProductsResponse), 200);
      });
      mockApiService = ApiService(client: client);
      viewModel = ProductViewModel(apiService: mockApiService);

      await viewModel.fetchProducts(isRefresh: true);

      // Filter price between 500 and 1000
      viewModel.setPriceRange(500.0, 1000.0);
      expect(viewModel.filteredProducts, hasLength(1));
      expect(viewModel.filteredProducts.first.id, 2); // Cheap Laptop ($899)
      expect(
        viewModel.activeFiltersCount,
        2,
      ); // minPrice and maxPrice are active
    });

    test('Filtering by rating works correctly', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(fakeProductsResponse), 200);
      });
      mockApiService = ApiService(client: client);
      viewModel = ProductViewModel(apiService: mockApiService);

      await viewModel.fetchProducts(isRefresh: true);

      // Filter rating >= 4.0
      viewModel.setMinimumRating('4+');
      expect(
        viewModel.filteredProducts,
        hasLength(2),
      ); // id=1 (4.5), id=3 (4.9)
      expect(viewModel.filteredProducts.any((p) => p.id == 2), isFalse);
    });

    test('Sorting sorts list properly', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(fakeProductsResponse), 200);
      });
      mockApiService = ApiService(client: client);
      viewModel = ProductViewModel(apiService: mockApiService);

      await viewModel.fetchProducts(isRefresh: true);

      // Sort Price Low to High
      viewModel.setSortOption('Price: Low to High');
      expect(viewModel.filteredProducts[0].price, 499.0);
      expect(viewModel.filteredProducts[1].price, 899.0);
      expect(viewModel.filteredProducts[2].price, 1599.0);

      // Sort Price High to Low
      viewModel.setSortOption('Price: High to Low');
      expect(viewModel.filteredProducts[0].price, 1599.0);
      expect(viewModel.filteredProducts[2].price, 499.0);

      // Sort Name A to Z
      viewModel.setSortOption('Name: A to Z');
      expect(viewModel.filteredProducts[0].title, 'Cheap Laptop');
      expect(viewModel.filteredProducts[1].title, 'High-end Laptop');
      expect(viewModel.filteredProducts[2].title, 'Test Smartphone X');
    });

    test(
      'Combination of search, category, rating, and sorting works together',
      () async {
        final client = MockClient((request) async {
          // Mock server side search return: only Laptops returned for search "Laptop"
          final searchResult = {
            'products': [
              fakeProductsResponse['products'][1],
              fakeProductsResponse['products'][2],
            ],
            'total': 2,
            'skip': 0,
            'limit': 20,
          };
          return http.Response(jsonEncode(searchResult), 200);
        });
        mockApiService = ApiService(client: client);
        viewModel = ProductViewModel(apiService: mockApiService);

        // Search for laptops
        viewModel.searchQuery.value = 'Laptop';
        await viewModel.fetchProducts(isRefresh: true);

        expect(
          viewModel.products,
          hasLength(2),
        ); // Cheap Laptop, High-end Laptop

        // Filter category to laptops, rating >= 4.0, sort High to Low
        viewModel.setCategory('laptops');
        viewModel.setMinimumRating('4+');
        viewModel.setSortOption('Price: High to Low');

        expect(viewModel.filteredProducts, hasLength(1));
        expect(
          viewModel.filteredProducts.first.id,
          3,
        ); // High-end Laptop ($1599, rating 4.9)
      },
    );

    test('Clear Filters restores original results', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(fakeProductsResponse), 200);
      });
      mockApiService = ApiService(client: client);
      viewModel = ProductViewModel(apiService: mockApiService);

      await viewModel.fetchProducts(isRefresh: true);

      viewModel.setCategory('laptops');
      viewModel.setPriceRange(100.0, 1000.0);
      viewModel.setMinimumRating('4+');
      viewModel.setSortOption('Name: A to Z');

      expect(viewModel.activeFiltersCount, 5);

      viewModel.clearFilters();

      expect(viewModel.activeFiltersCount, 0);
      expect(viewModel.selectedCategory.value, 'All');
      expect(viewModel.filteredProducts, hasLength(3));
    });
  });
}
