class TransactionModel {
  final String id;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      totalAmount: (json['total_amount'] is int)
          ? (json['total_amount'] as int).toDouble()
          : json['total_amount'],
      paymentMethod: json['payment_method'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}