import 'package:get/get.dart';
import '../view/home_view.dart';
import '../view/product_detail_view.dart';

class AppRoutes {
  static const String home = '/home';
  static const String productDetail = '/product/:id';

  static final List<GetPage> pages = [
    GetPage(
      name: home,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: productDetail,
      page: () => const ProductDetailView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
