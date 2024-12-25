import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../utils/currency_formatter.dart';

class TransactionScreen extends StatefulWidget {
  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();

  List<Category> categories = [];
  Map<String, List<Product>> categorizedProducts = {};
  bool isLoading = true;
  String searchQuery = '';
  Map<String, int> cart = {};

  @override
  void initState() {
    super.initState();
    loadCategoriesAndProducts();
  }

  void loadCategoriesAndProducts() async {
    final loadedCategories = await _categoryService.fetchCategories();
    final Map<String, List<Product>> productsMap = {};

    for (var category in loadedCategories) {
      productsMap[category.name] =
          await _productService.fetchProductsByCategory(category.id);
    }

    setState(() {
      categories = loadedCategories;
      categorizedProducts = productsMap;
      isLoading = false;
    });
  }

  void filterProducts(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  void incrementProduct(Product product) {
    setState(() {
      cart.update(product.id, (quantity) => quantity + 1, ifAbsent: () => 1);
    });
  }

  void decrementProduct(Product product) {
    setState(() {
      if (cart.containsKey(product.id) && cart[product.id]! > 1) {
        cart.update(product.id, (quantity) => quantity - 1);
      } else {
        cart.remove(product.id);
      }
    });
  }

  int getTotalCartItems() {
    return cart.values.fold(0, (sum, quantity) => sum + quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Transaksi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterProducts,
              decoration: InputDecoration(
                hintText: 'Cari Produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final products = categorizedProducts[category.name] ?? [];

                      final filteredProducts = products.where((product) {
                        return product.name
                            .toLowerCase()
                            .contains(searchQuery);
                      }).toList();

                      return ExpansionTile(
                        title: Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        initiallyExpanded: true,
                        children: filteredProducts.map((product) {
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                                'Harga: ${formatRupiah(product.price)} | Stok: ${product.stock}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, color: Colors.red),
                                  onPressed: () => decrementProduct(product),
                                ),
                                Text(
                                  cart[product.id]?.toString() ?? '0',
                                  style: TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add, color: Colors.blue),
                                  onPressed: () => incrementProduct(product),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/cart', arguments: {'cart': cart});
                },
                icon: Stack(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.white),
                    if (cart.isNotEmpty)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${getTotalCartItems()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: Text(
                  'Lihat Keranjang',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Color(0xFF6A11CB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
