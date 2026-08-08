# Catalogify - Product Catalog App

A premium Flutter product catalog application built with Dart, utilizing the GetX state management framework and following clean MVVM architecture patterns. The app consumes mock product catalog APIs from DummyJSON.

---

## Features

- **Product Listing**: Displays a scrollable list of products with high-fidelity UI cards showing titles, brands/categories, ratings, discount percentages, and final prices.
- **Product Search**: Interactive instant search with client-side request debouncing (500ms) to minimize unnecessary network traffic.
- **Product Details**: Dedicated detailed views featuring pricing, ratings, categories, description, stock status, and an interactive image gallery.
- **Loading State**: Customized smooth loading spinners indicating data retrieval.
- **Error State**: Elegant full-screen error widgets with connection/timeout diagnosis messages and visual "Try Again" recovery actions.
- **Empty State**: Friendly user guides with options to clear filters and restart product discovery.
- **Pull-to-refresh**: Quick pull actions to sync catalog lists on the fly.
- **Pagination**: Efficient infinite scrolling utilizing skip/limit query offsets for optimal resource use.
- **GetX State Management**: Highly responsive reactive observables (`RxList`, `RxBool`, `Rxn`) and simplified route transitions.
- **MVVM Architecture**: Strict separation of user interface (View), controller logic (ViewModel), data adapters (ApiService), and models (ProductModel).
- **Cached Images**: Highly optimized cached network image loaders with local caching, loaders, and broken-image fallbacks.
- **Dark Mode**: Fully native theme adaptiveness to device light/dark preferences.

---

## Tech Stack

- **Flutter**: Stable Mobile Framework.
- **Dart**: Strong typed programming language.
- **GetX**: High performance, lightweight state management, and routing.
- **http**: Dart's standard HTTP package for clean, dependency-lean REST API integration.
- **cached_network_image**: Feature-rich local image downloader and cacher.
- **DummyJSON**: Public REST API server.

---

## Architecture

The project adheres to the Model-View-ViewModel (MVVM) software architectural pattern:

```
View (UI & Layouts)
   │
   ▼
ViewModel (Reactive GetxController)
   │
   ▼
ApiService (HTTP Client & Error Interception)
   │
   ▼
http (Standard Dart Client)
   │
   ▼
DummyJSON (REST API endpoints)
```

### Responsibilities:
- **Model**: Defines data interfaces and robust JSON parsers (`ProductModel` & `ProductsResponseModel`) handling edge-cases like type casting and nullable attributes.
- **View**: Simple, declaration-only declarative UI layer (`HomeView` & `ProductDetailView`). Completely decoupled from network calls and business rules.
- **ViewModel**: Manages the application reactive states, pagination offsets, search debouncing logic, and requests API updates.
- **Core**: Contains configuration constants, themes (light/dark schemes), and shared modular widgets (loading, empty state, errors).

---

## API Endpoints

The application utilizes the following REST endpoints:

- **List Products**: `GET /products`
- **Search Products**: `GET /products/search?q={query}`
- **Product Detail**: `GET /products/{id}`

*All query URLs inherit the base configuration: `https://dummyjson.com`*

---

## Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   ├── services/
│   │   └── api_service.dart
│   ├── theme/
│   │   ├── dark_theme.dart
│   │   └── light_theme.dart
│   └── widgets/
│       ├── empty_widget.dart
│       ├── error_widget.dart
│       └── loading_widget.dart
├── model/
│   └── product_model.dart
├── routes/
│   └── app_routes.dart
├── view/
│   ├── home_view.dart
│   ├── product_detail_view.dart
│   └── widgets/
│       ├── product_card.dart
│       └── search_bar.dart
├── viewmodel/
│   └── product_viewmodel.dart
└── main.dart

test/
├── unit_test.dart
└── widget_test.dart
```

---

## How to Run

1. Clone this repository to your local machine.
2. Install the package dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## Run Tests

Execute unit and widget tests:
```bash
flutter test
```

---

## Analyze

Run static code analysis:
```bash
flutter analyze
```

---

## Build APK

Generate a release Android APK:
```bash
flutter build apk --release
```

The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Screenshots

### Product List
*(Insert product list screenshot here)*

### Search
*(Insert search queries results screenshot here)*

### Product Details
*(Insert product detail page and interactive gallery screenshot here)*

### Dark Mode
*(Insert dark mode interface screenshot here)*

### Error State
*(Insert connection error with retry action screenshot here)*
