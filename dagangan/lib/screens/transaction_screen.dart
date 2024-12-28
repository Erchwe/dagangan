import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../utils/currency_formatter.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

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
      appBar: AppBar(title: const Text('Transaction Input')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLandscape = constraints.maxWidth > constraints.maxHeight;

          return isLandscape
              ? Row(
                  children: [
                    Expanded(
                      flex: cart.isNotEmpty ? 3 : 5,
                      child: _buildProductListByCategory(),
                    ),

                    if (cart.isNotEmpty)
                      Container(
                        width: 1,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),

                    /// Keranjang (40%)
                    if (cart.isNotEmpty)
                      Expanded(
                        flex: 2,
                        child: _buildCart(),
                      ),
                  ],
                )
              : Column(
                  children: [
                    /// Daftar Produk (60%)
                    Expanded(
                      flex: cart.isNotEmpty ? 3 : 5,
                      child: _buildProductListByCategory(),
                    ),

                    /// Garis Horizontal jika keranjang tidak kosong
                    if (cart.isNotEmpty)
                      Container(
                        height: 1,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),

                    /// Keranjang (40%)
                    if (cart.isNotEmpty)
                      Expanded(
                        flex: 2,
                        child: _buildCart(),
                      ),
                  ],
                );
        },
      ),
    );
  }

  /// Widget Produk per Kategori dengan Search Bar
  Widget _buildProductListByCategory() {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200
        ? 4
        : screenWidth > 800
            ? 3
            : 2;

    return Column(
      children: [
        /// Search Bar di bagian atas
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: filterProducts,
            decoration: InputDecoration(
              hintText: 'Search Products',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final products = categorizedProducts[category.name] ?? [];

                    final filteredProducts = products.where((product) {
                      return product.name.toLowerCase().contains(searchQuery);
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, productIndex) {
                            final product = filteredProducts[productIndex];
                            return HoverableCard(
                              title: product.name,
                              subtitle:
                                  '${formatRupiah(product.price)} | Stok: ${product.stock}',
                              icon: Icons.shopping_cart,
                              onTap: () => incrementProduct(product),
                              onRemove: () => decrementProduct(product),
                              cartCount: cart[product.id]?.toString() ?? '0',
                            );
                          },
                        ),
                        Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                          height: 32,
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  void clearCart() {
    setState(() {
      cart.clear();
    });
  }

  Widget _buildCart() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: clearCart,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Clear Cart',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: cart.entries.map((entry) {
                final product = categorizedProducts.values
                    .expand((list) => list)
                    .firstWhere((p) => p.id == entry.key);
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(formatRupiah(product.price)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.red),
                        onPressed: () => decrementProduct(product),
                      ),
                      Text('x${entry.value}'),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () => incrementProduct(product),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {
        bool stockValid = true;
        String errorMessage = '';

        for (var entry in cart.entries) {
          final product = categorizedProducts.values
              .expand((list) => list)
              .firstWhere((p) => p.id == entry.key);

          if (product.stock == 0) {
            stockValid = false;
            errorMessage = '${product.name} is out of stock.';
            break;
          }

          if (entry.value > product.stock) {
            stockValid = false;
            errorMessage =
                '${product.name} quantity exceeds the available stock. Available stock: (${product.stock}).';
            break;
          }
        }

        if (!stockValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        // Jika stok valid, lanjutkan ke halaman pembayaran
        Navigator.pushNamed(
          context,
          '/confirm-payment',
          arguments: {
            'cart': cart,
            'products': categorizedProducts.values.expand((list) => list).toList(),
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Confirm Payment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 12),
          Icon(
            Icons.arrow_forward,
            size: 24,
            color: Colors.white,
          ),
        ],
      ),
    ),
  ),
),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

}


/// Widget HoverableCard
class HoverableCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final String cartCount;

  const HoverableCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.onRemove,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: onRemove,
                ),
                Text(
                  cartCount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: onTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}