import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches all products from the API.
  Future<List<dynamic>> fetchProducts() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsEndpoint}');
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load products: Server responded with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  /// Fetches all product categories.
  Future<List<String>> fetchCategories() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categoriesEndpoint}');
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item.toString()).toList();
      } else {
        throw Exception('Failed to load categories: Server responded with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  /// Fetches a single product by its ID.
  Future<Map<String, dynamic>> fetchProductById(int id) async {
    try {
      final url = Uri.parse(ApiConstants.productDetailUrl(id));
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load product details: Server responded with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
