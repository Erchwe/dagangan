import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_screen.dart';
import '../screens/category_screen.dart';
import '../screens/transaction_screen.dart';
import '../screens/confirm_payment_screen.dart';
import '../screens/cash_input_screen.dart';
import '../screens/success_screen.dart';
import '../screens/manager_dashboard_screen.dart';
import '../screens/sales_report_screen.dart';

import '../models/product_model.dart';


/// Definisi semua rute dalam aplikasi
final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/manager-dashboard': (context) => const ManagerDashboardScreen(),
  '/categories': (context) => const CategoryScreen(),
  '/products': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return ProductScreen(
      categoryId: args['categoryId']!,
      categoryName: args['categoryName']!,
    );
  },
  '/transaction': (context) => const TransactionScreen(),
  '/confirm-payment': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ConfirmPaymentScreen(
      cart: args['cart'] as Map<String, int>,
      products: args['products'] as List<Product>,
      paymentMethod: args['paymentMethod'] as String,
      totalAmount: (args['totalAmount'] != null) 
        ? (args['totalAmount'] as num).toDouble()
        : 0.0,
      cashier: args['cashier'] as String,
      change: (args['change'] != null) 
        ? (args['change'] as num).toDouble()
        : 0.0,
      cashDenominations: (args['cashDenominations'] != null)
          ? (args['cashDenominations'] as Map).map<int, int>((key, value) => MapEntry(key as int, value as int))
          : null,
      changeDenominations: (args['changeDenominations'] != null)
          ? (args['changeDenominations'] as Map).map<int, int>((key, value) => MapEntry(key as int, value as int))
          : null,
    );
  },
  '/cash-input': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return CashInputScreen(
      cart: args['cart'] as Map<String, int>,
      products: args['products'] as List<Product>,
      paymentMethod: args['paymentMethod'] as String,
      totalAmount: args['totalAmount'] as double,
      cashier: args['cashier'] as String,
    );
  },
  '/success': (context) => const SuccessScreen(),
  '/sales-reports': (context) => const SalesReportScreen(),

};
