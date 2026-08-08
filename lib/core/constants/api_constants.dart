class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';
  static const String productsEndpoint = '/products';
  static const String searchEndpoint = '/products/search';

  // Helper method to build url for fetching a single product
  static String productDetailUrl(int id) => '$productsEndpoint/$id';
}
