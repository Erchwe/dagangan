class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String categoryId;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: (json['price'] is int) 
          ? (json['price'] as int).toDouble() // Konversi int ke double jika perlu
          : json['price'], // Jika sudah double, langsung digunakan
      stock: json['stock'],
      categoryId: json['category'],
      description: json['product_desc'], // Pastikan sesuai dengan kolom di database
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'category': categoryId,
      'product_desc': description,
    };
  }
}
