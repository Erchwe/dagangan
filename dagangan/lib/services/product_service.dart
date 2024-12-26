import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  /// **Fetch Products by Category**
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    final response = await supabase
        .from('products')
        .select('*')
        .eq('category', categoryId);

    if (response == null || response.isEmpty) {
      return [];
    }

    return response.map<Product>((e) => Product.fromJson(e)).toList();
  }

  /// **Add Product**
  Future<void> addProduct(Product product) async {
    await supabase.from('products').insert({
      'name': product.name,
      'product_desc': product.description,
      'price': product.price,
      'stock': product.stock,
      'category': product.categoryId,
    });
  }


  /// **Update Product**
  Future<void> updateProduct(Product product) async {
    print('Updating Product with Category ID: ${product.categoryId}');

    try {
      await Supabase.instance.client
          .from('products')
          .update({
            'name': product.name,
            'price': product.price,
            'stock': product.stock,
            'category': product.categoryId, // Pastikan ini benar
            'product_desc': product.description, // Menggunakan kolom yang benar
          })
          .eq('id', product.id);

      print('Product successfully updated in database');
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Failed to update product');
    }
  }


  /// **Delete Product**
  Future<void> deleteProduct(String productId) async {
    await supabase.from('products').delete().eq('id', productId);
  }

  /// **Fetch Single Product**
  Future<Product?> fetchProductById(String productId) async {
    final response = await supabase
        .from('products')
        .select('*')
        .eq('id', productId)
        .single();

    if (response == null) {
      return null;
    }

    return Product.fromJson(response);
  }
}
