class ApiConstants {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/products/categories';

  // Helper method to build url for fetching a single product
  static String productDetailUrl(int id) => '$baseUrl$productsEndpoint/$id';
}
