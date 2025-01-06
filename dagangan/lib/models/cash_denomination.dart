class CashDenomination {
  final int id;
  final int denomination;
  final int quantity;

  CashDenomination({
    required this.id,
    required this.denomination,
    required this.quantity,
  });

  factory CashDenomination.fromJson(Map<String, dynamic> json) {
    return CashDenomination(
      id: json['id'],
      denomination: json['denomination'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'denomination': denomination,
      'quantity': quantity,
    };
  }
}
