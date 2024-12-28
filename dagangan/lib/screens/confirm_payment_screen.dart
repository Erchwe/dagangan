import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/currency_formatter.dart';

class ConfirmPaymentScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<dynamic> products;
  final String paymentMethod;
  final double totalAmount;
  final String cashier;
  final Map<int, int>? cashDenominations;
  final Map<int, int>? changeDenominations;

  const ConfirmPaymentScreen({
    super.key,
    required this.cart,
    required this.products,
    required this.paymentMethod,
    required this.totalAmount,
    required this.cashier,
    this.cashDenominations,
    this.changeDenominations,
  });

  @override
  State<ConfirmPaymentScreen> createState() => _ConfirmPaymentScreenState();
}

class _ConfirmPaymentScreenState extends State<ConfirmPaymentScreen> {
  bool isLoading = false;

  /// Fungsi untuk menyimpan transaksi ke database
  Future<void> saveTransaction() async {
    setState(() {
      isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Hitung Grand Total jika tidak tersedia di widget.totalAmount
      double grandTotal = widget.totalAmount;

      if (grandTotal == 0.0) {
        grandTotal = widget.cart.entries.fold(0.0, (total, entry) {
          final product = widget.products.firstWhere((p) => p.id == entry.key);
          return total + (product.price * entry.value);
        });
      }

      // Simpan transaksi ke tabel 'transactions'
      final response = await supabase.from('transactions').insert({
        'total_amount': widget.totalAmount,
        'payment_method': widget.paymentMethod,
        'cashier': widget.cashier,
        'cash_given': widget.paymentMethod == 'cash' ? widget.totalAmount : null,
        'change': widget.paymentMethod == 'cash' ? (widget.totalAmount - widget.totalAmount) : null,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      print('Transaction Saved: $response');

      // **Update stok produk**
      for (var entry in widget.cart.entries) {
        final productId = entry.key;
        final quantity = entry.value;

        final product = await supabase
            .from('products')
            .select('stock')
            .eq('id', productId)
            .single();

        if (product != null) {
          final currentStock = product['stock'] as int;
          final updatedStock = currentStock - quantity;

          if (updatedStock >= 0) {
            await supabase.from('products').update({
              'stock': updatedStock,
            }).eq('id', productId);
          } else {
            throw Exception('Stock insufficient for product ID: $productId');
          }
        }
      }

      // **Perbarui cash jika metode pembayaran cash**
      // Update Cash Denominations
      if (widget.paymentMethod == 'cash' && widget.cashDenominations != null) {
        for (var entry in widget.cashDenominations!.entries) {
          final denomination = entry.key; // Pecahan uang (100000, 50000, dll.)
          final quantity = entry.value; // Jumlah lembar uang

          if (quantity > 0) {
            // Periksa stok saat ini
            final existingCash = await supabase
                .from('cash')
                .select('quantity')
                .eq('denomination', denomination)
                .single();

            if (existingCash != null) {
              final currentQuantity = existingCash['quantity'] as int;
              final updatedQuantity = currentQuantity + quantity;

              // Update jumlah stok uang tunai
              await supabase.from('cash').update({
                'quantity': updatedQuantity,
              }).eq('denomination', denomination);
            }
          }
        }
      }

      // Kurangi stok untuk kembalian
      if (widget.paymentMethod == 'cash' && widget.changeDenominations != null) {
        for (var entry in widget.changeDenominations!.entries) {
          final denomination = entry.key; // Pecahan uang
          final quantity = entry.value; // Jumlah uang untuk kembalian

          if (quantity > 0) {
            // Periksa stok saat ini
            final existingCash = await supabase
                .from('cash')
                .select('quantity')
                .eq('denomination', denomination)
                .single();

            if (existingCash != null) {
              final currentQuantity = existingCash['quantity'] as int;

              // Pastikan stok cukup untuk dikurangi
              if (currentQuantity >= quantity) {
                final updatedQuantity = currentQuantity - quantity;

                // Update jumlah stok uang tunai untuk kembalian
                await supabase.from('cash').update({
                  'quantity': updatedQuantity,
                }).eq('denomination', denomination);
              } else {
                throw Exception(
                    'Insufficient cash stock for denomination: $denomination');
              }
            }
          }
        }
      }


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/success');
    } catch (e) {
      print('Failed to save transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  /// Mendapatkan daftar barang berdasarkan cart
  List<Widget> _buildProductList() {
    return widget.cart.entries.map((entry) {
      final product = widget.products.firstWhere((p) => p.id == entry.key);
      final qty = entry.value;
      final totalPrice = product.price * qty;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ikon Barang
            const Icon(Icons.shopping_cart, size: 40, color: Colors.deepPurple),
            const SizedBox(width: 12),

            // Nama Barang & Qty
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text('Qty: $qty', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),

            // Harga Satuan & Total Harga
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${formatRupiah(product.price)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${formatRupiah(totalPrice)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Menampilkan Cash Denominations & Change jika ada
  List<Widget> _buildPaymentDetails() {
    List<Widget> details = [
      _buildSummaryRow('Grand Total', formatRupiah(widget.totalAmount)),
      _buildSummaryRow('Payment Method', widget.paymentMethod),
    ];

    if (widget.cashDenominations != null &&
        widget.paymentMethod == 'cash') {
      details.add(_buildSummaryRow('Cash Denominations', ''));
      details.addAll(
        widget.cashDenominations!.entries
            .where((entry) => entry.value > 0)
            .map((entry) => _buildSummaryRow(
                '${entry.value} x ${formatRupiah(entry.key.toDouble())}', '')),
      );
    }

    if (widget.changeDenominations != null &&
        widget.paymentMethod == 'cash') {
      details.add(_buildSummaryRow('Change Denominations', ''));
      details.addAll(
        widget.changeDenominations!.entries
            .where((entry) => entry.value > 0)
            .map((entry) => _buildSummaryRow(
                '${entry.value} x ${formatRupiah(entry.key.toDouble())}', '')),
      );
    }

    return details;
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Summary'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Purchased Items
              const Text(
                'Purchased Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._buildProductList(),
              const SizedBox(height: 24),

              // Section: Payment Details
              const Divider(),
              const Text(
                'Payment Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._buildPaymentDetails(),
              const SizedBox(height: 24),

              // Button Confirm Payment
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Confirm Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}