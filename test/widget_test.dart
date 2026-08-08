import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:product_catalog_app/core/services/api_service.dart';
import 'package:product_catalog_app/model/product_model.dart';
import 'package:product_catalog_app/core/widgets/loading_widget.dart';
import 'package:product_catalog_app/core/widgets/empty_widget.dart';
import 'package:product_catalog_app/core/widgets/error_widget.dart';
import 'package:product_catalog_app/view/widgets/product_grid_card.dart';
import 'package:product_catalog_app/view/widgets/search_bar.dart';
import 'package:product_catalog_app/view/widgets/filter_bottom_sheet.dart';
import 'package:product_catalog_app/viewmodel/product_viewmodel.dart';

// Helper wrapper to initialize ScreenUtil for widget testing
Widget wrapWithScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 690),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => GetMaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  late ProductViewModel viewModel;

  setUp(() {
    final client = MockClient((request) async {
      return http.Response('{"products": [], "total": 0}', 200);
    });
    final apiService = ApiService(client: client);
    viewModel = Get.put<ProductViewModel>(
      ProductViewModel(apiService: apiService),
    );
    // Seed some mock categories
    viewModel.categories.value = ['All', 'smartphones', 'laptops'];
  });

  tearDown(() {
    Get.delete<ProductViewModel>();
  });

  group('LoadingWidget Tests', () {
    testWidgets('renders default and custom message correctly', (tester) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithScreenUtil(const LoadingWidget()));
      expect(find.text('Loading products...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        wrapWithScreenUtil(const LoadingWidget(message: 'Please wait')),
      );
      expect(find.text('Please wait'), findsOneWidget);
    });
  });

  group('EmptyWidget Tests', () {
    testWidgets('renders title, description and handles clear callback', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool clearClicked = false;

      await tester.pumpWidget(
        wrapWithScreenUtil(
          EmptyWidget(
            title: 'Empty List',
            message: 'No products here',
            onClearFilters: () {
              clearClicked = true;
            },
          ),
        ),
      );

      expect(find.text('Empty List'), findsOneWidget);
      expect(find.text('No products here'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);

      final clearButton = find.byType(OutlinedButton);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();

      expect(clearClicked, isTrue);
    });
  });

  group('AppErrorWidget Tests', () {
    testWidgets('renders error message and triggers retry callback', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool retryClicked = false;

      await tester.pumpWidget(
        wrapWithScreenUtil(
          AppErrorWidget(
            errorMessage: 'Network failed',
            onRetry: () {
              retryClicked = true;
            },
          ),
        ),
      );

      expect(find.text('Network failed'), findsOneWidget);
      expect(find.text('Oops! Something went wrong'), findsOneWidget);

      final retryButton = find.byType(ElevatedButton);
      expect(retryButton, findsOneWidget);
      await tester.tap(retryButton);
      await tester.pump();

      expect(retryClicked, isTrue);
    });
  });

  group('CustomSearchBar Tests', () {
    testWidgets('renders with initial text and propagates changes', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String searchValue = 'initial';

      await tester.pumpWidget(
        wrapWithScreenUtil(
          CustomSearchBar(
            initialValue: searchValue,
            onChanged: (val) {
              searchValue = val;
            },
            hintText: 'Search here...',
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // Inputting new text
      await tester.enterText(find.byType(TextField), 'headphones');
      expect(searchValue, 'headphones');

      // Clear button should render when text is not empty
      await tester.pumpAndSettle();
      final clearButton = find.byType(IconButton);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(searchValue, isEmpty);
    });
  });

  group('ProductGridCard Tests', () {
    final testProduct = ProductModel(
      id: 1,
      title: 'Awesome Sneakers',
      description: 'Sneakers for walking',
      category: 'shoes',
      price: 99.99,
      discountPercentage: 15.0,
      rating: 4.8,
      stock: 25,
      brand: 'Adidas',
      thumbnail: 'https://example.com/sneaker.png',
      images: ['https://example.com/sneaker.png'],
    );

    testWidgets('renders grid card details and handles taps', (tester) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool tapped = false;

      await tester.pumpWidget(
        wrapWithScreenUtil(
          ProductGridCard(
            product: testProduct,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      expect(find.text('Awesome Sneakers'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
      expect(find.text('Adidas'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('-15%'), findsOneWidget);

      await tester.tap(find.byType(ProductGridCard));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('FilterBottomSheet Tests', () {
    testWidgets('displays header, chips and updates filter states on apply', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithScreenUtil(const FilterBottomSheet()));

      // Validate title and clear button
      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);

      // Validate category chips are rendered
      expect(find.text('SMARTPHONES'), findsOneWidget);
      expect(find.text('LAPTOPS'), findsOneWidget);

      // Enter min/max prices
      await tester.enterText(
        find.widgetWithText(TextField, 'Minimum Price'),
        '100',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Maximum Price'),
        '800',
      );

      // Select rating chip 4+
      await tester.tap(find.text('4+'), warnIfMissed: false);
      await tester.pump();

      // Tap Apply Filters
      await tester.tap(find.text('Apply Filters'));
      await tester.pump();

      // Verify states are updated in ViewModel
      expect(viewModel.minPrice.value, 100.0);
      expect(viewModel.maxPrice.value, 800.0);
      expect(viewModel.minimumRating.value, '4+');
    });

    testWidgets('Clear All button resets filters locally and globally', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Set some filters beforehand
      viewModel.selectedCategory.value = 'laptops';
      viewModel.minimumRating.value = '4+';
      viewModel.minPrice.value = 50.0;
      viewModel.maxPrice.value = 250.0;
      viewModel.selectedSort.value = 'Price: High to Low';

      await tester.pumpWidget(wrapWithScreenUtil(const FilterBottomSheet()));

      // Tap Clear All
      await tester.tap(find.text('Clear All'));
      await tester.pump();

      // Verify states are reset in ViewModel
      expect(viewModel.selectedCategory.value, 'All');
      expect(viewModel.minimumRating.value, 'All');
      expect(viewModel.minPrice.value, isNull);
      expect(viewModel.maxPrice.value, isNull);
      expect(viewModel.selectedSort.value, 'Default');
    });
  });
}
