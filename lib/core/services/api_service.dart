import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Sends a GET request and handles errors.
  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception(
        'Connection timeout. Please check your internet connection.',
      );
    } on SocketException {
      throw Exception(
        'No internet connection. Please verify your connection status.',
      );
    } catch (e) {
      if (e is HttpException) {
        throw Exception('HTTP error occurred: ${e.message}');
      }
      if (e is FormatException) {
        throw Exception('Bad response format from server.');
      }
      if (e is Exception && e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Sends a POST request and handles errors.
  Future<http.Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      final response = await _client
          .post(
            uri,
            body: data != null ? jsonEncode(data) : null,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception(
        'Connection timeout. Please check your internet connection.',
      );
    } on SocketException {
      throw Exception(
        'No internet connection. Please verify your connection status.',
      );
    } catch (e) {
      if (e is HttpException) {
        throw Exception('HTTP error occurred: ${e.message}');
      }
      if (e is FormatException) {
        throw Exception('Bad response format from server.');
      }
      if (e is Exception && e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Fetches the list of product categories.
  Future<List<String>> fetchCategories() async {
    final response = await get('/products/category-list');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => item.toString()).toList();
  }

  http.Response _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      return response;
    } else {
      String message = 'Server error';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('message')) {
          message = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception('Server error ($statusCode): $message');
    }
  }
}
