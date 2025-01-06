class TransactionModel {
  final String id;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;
  final String cashier;

  TransactionModel({
    required this.id,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    required this.cashier,
  });

factory TransactionModel.fromJson(Map<String, dynamic> json) {
  return TransactionModel(
    id: json['id'] ?? 'Unknown', 
    totalAmount: json['total_amount'] == null
        ? 0.0 
        : (json['total_amount'] is int)
            ? (json['total_amount'] as int).toDouble()
            : json['total_amount'],
    paymentMethod: json['payment_method'] ?? 'Unknown', 
    createdAt: json['created_at'] == null
        ? DateTime.now() 
        : DateTime.parse(json['created_at']),
    cashier: json['cashier'] ?? 'Unknown',
  );
}

}
