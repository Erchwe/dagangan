import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../utils/currency_formatter.dart';
import 'edit_product_screen.dart';
import 'add_product_screen.dart';

class ProductScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ProductScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  /// Memuat daftar produk berdasarkan kategori
  void loadProducts() async {
    final data = await _productService.fetchProductsByCategory(widget.categoryId);
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  /// Navigasi ke halaman edit produk
  void editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    ).then((_) => loadProducts()); // Refresh daftar produk setelah edit
  }

  /// Menghapus produk dengan konfirmasi
  void deleteProduct(Product product) async {
    final isReferenced = await _productService.isProductInTransactionDetails(product.id);
    
    if (isReferenced) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product "${product.name}" cannot be deleted as it is referenced in transactions.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: Text('Are you sure you want to delete the product "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _productService.deleteProduct(product.id);
      loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product successfully deleted.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products - ${widget.categoryName}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products available for this category.'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      elevation: 2,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.shopping_bag, color: Colors.white),
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          'Price: ${formatRupiah(product.price)}\nStock: ${product.stock}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () => editProduct(product),
                              tooltip: 'Edit Product',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProduct(product),
                              tooltip: 'Delete Product',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(
                categoryId: widget.categoryId,
                categoryName: widget.categoryName,
              ),
            ),
          ).then((_) => loadProducts()); // Refresh produk setelah menambah produk baru
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
        label: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
