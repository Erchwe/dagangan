import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_screen.dart';
import '../screens/category_screen.dart';
import '../screens/transaction_screen.dart';

/// Definisi semua rute dalam aplikasi
final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/categories': (context) => const CategoryScreen(),
  '/products': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return ProductScreen(
      categoryId: args['categoryId']!,
      categoryName: args['categoryName']!,
    );
  },
  '/transaction': (context) => TransactionScreen(),
};
