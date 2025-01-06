import 'transaction_model.dart';

class TransactionDetail {
  final String id;
  final String transactionId;
  final String productId;
  final String productName; // Tambahkan nama produk
  final int quantity;
  final double price;
  final double subtotal;
  final TransactionModel transaction;

  TransactionDetail({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.transaction,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      id: json['id'],
      transactionId: json['transaction_id'],
      productId: json['product_id'],
      productName: json['products']['name'] ?? 'Unknown', // Ambil nama produk
      quantity: json['quantity'] as int,
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'] as double,
      subtotal: (json['subtotal'] is int)
          ? (json['subtotal'] as int).toDouble()
          : json['subtotal'] as double,
      transaction: TransactionModel.fromJson(json['transactions']),
    );
  }
}
