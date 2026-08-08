import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog_app/model/product_model.dart';

void main() {
  group('ProductModel Tests', () {
    test('ProductModel.fromJson should parse valid JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'description': 'A description',
        'category': 'test',
        'price': 9.99,
        'discountPercentage': 1.5,
        'rating': 4.5,
        'stock': 10,
        'brand': 'TestBrand',
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/image1.jpg'],
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.description, 'A description');
      expect(product.category, 'test');
      expect(product.price, 9.99);
      expect(product.discountPercentage, 1.5);
      expect(product.rating, 4.5);
      expect(product.stock, 10);
      expect(product.brand, 'TestBrand');
      expect(product.thumbnail, 'https://example.com/thumb.jpg');
      expect(product.images, ['https://example.com/image1.jpg']);
    });

    test('ProductsResponseModel.fromJson should parse valid list JSON correctly', () {
      final json = {
        'products': [
          {
            'id': 1,
            'title': 'P1',
            'description': 'D1',
            'category': 'C1',
            'price': 100,
            'discountPercentage': 5,
            'rating': 4.0,
            'stock': 50,
            'brand': 'B1',
            'thumbnail': 'T1',
            'images': ['I1'],
          }
        ],
        'total': 1,
        'skip': 0,
        'limit': 10,
      };

      final response = ProductsResponseModel.fromJson(json);

      expect(response.total, 1);
      expect(response.skip, 0);
      expect(response.limit, 10);
      expect(response.products.length, 1);
      expect(response.products.first.title, 'P1');
    });
  });
}
