import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/currency_formatter.dart';
import '../models/product_model.dart';

class ConfirmPaymentScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<Product> products;

  const ConfirmPaymentScreen({
    super.key,
    required this.cart,
    required this.products,
  });

  @override
  State<ConfirmPaymentScreen> createState() => _ConfirmPaymentScreenState();
}

class _ConfirmPaymentScreenState extends State<ConfirmPaymentScreen> {
  String cashierName = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchCashierName();
  }

  /// Mengambil Nama Kasir dari Metadata Pengguna
  Future<void> fetchCashierName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.userMetadata != null) {
        setState(() {
          cashierName = user.userMetadata?['display_name'] ?? 'No Display Name';
        });
      } else {
        setState(() {
          cashierName = 'Guest';
        });
      }
    } catch (e) {
      setState(() {
        cashierName = 'Error fetching name';
      });
      print('Error fetching cashier name: $e');
    }
  }

  /// Menghitung total harga
  double getTotalPrice() {
    double total = 0.0;
    widget.cart.forEach((productId, quantity) {
      final product = widget.products.firstWhere((p) => p.id == productId);
      total += product.price * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        centerTitle: true, // Judul di tengah
      ),
      body: Column(
        children: [
          // 🛒 Daftar Produk di Keranjang
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Transaction Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final productId = widget.cart.keys.elementAt(index);
                final quantity = widget.cart[productId]!;
                final product = widget.products.firstWhere((p) => p.id == productId);

                return ListTile(
                  leading: const Icon(
                    Icons.shopping_bag,
                    color: Colors.deepPurple,
                    size: 30,
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Qty: $quantity',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: Text(
                    formatRupiah(product.price * quantity),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),

          // 📊 Ringkasan Total Harga + Nama Kasir
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Colors.grey.shade100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatRupiah(getTotalPrice()),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Cashier: $cashierName',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // 🔘 Tombol Cash Payment & Cashless Payment
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cash Payment Selected')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.money, color: Colors.white),
                    label: const Text(
                      'Cash Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cashless Payment Selected')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.credit_card, color: Colors.white),
                    label: const Text(
                      'Cashless Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
