import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/currency_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CashInputScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<Product> products;
  final String paymentMethod;
  final double totalAmount; 
  final String cashier;
  final Map<int, int>? cashDenominations;
  final Map<int, int>? changeDenominations;

  const CashInputScreen({
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
  State<CashInputScreen> createState() => _CashInputScreenState();
}

class _CashInputScreenState extends State<CashInputScreen> {
  final Map<int, int> cashDenominations = {
    100000: 0,
    50000: 0,
    20000: 0,
    10000: 0,
    5000: 0,
    2000: 0,
    1000: 0,
    500: 0,
    200: 0,
    100: 0
  };

  Map<int, int> cashStock = {};
  final Map<int, TextEditingController> controllers = {};
  double totalAmount = 0.0;
  double grandTotal = 0.0;
  Map<int, int> changeDenominations = {};
  String displayName = 'Unknown Cashier';

  @override
  void initState() {
    super.initState();
    fetchDisplayName();
    fetchCashStock();
    calculateGrandTotal();
    cashDenominations.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> fetchCashStock() async {
    try {
      final response = await Supabase.instance.client.from('cash').select('*').execute();

      if (response.status == 200 && response.data != null) {
        setState(() {
          cashStock = {
            for (var cash in response.data) cash['denomination'] as int: cash['quantity'] as int
          };
        });
        print('Fetched Cash Stock: $cashStock'); // Debug
      } else {
        print('Error fetching cash stock: ${response.status}, ${response.data}');
      }
    } catch (e) {
      print('Error fetching cash stock: $e');
    }
  }



  Future<void> fetchDisplayName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.userMetadata != null) {
        setState(() {
          displayName = user.userMetadata?['display_name'] ?? 'No Display Name';
        });
      }
    } catch (e) {
      setState(() {
        displayName = 'Error fetching display name';
      });
      print('Error fetching display name: $e');
    }
  }

  /// Menghitung total pembayaran
  void calculateGrandTotal() {
    double total = 0.0;
    widget.cart.forEach((productId, quantity) {
      final product = widget.products.firstWhere((p) => p.id == productId);
      total += product.price * quantity;
    });
    setState(() {
      grandTotal = total;
    });
  }

  /// Menghitung total uang tunai yang dimasukkan
  void calculateTotalCash() {
    double total = 0.0;
    cashDenominations.forEach((denomination, count) {
      total += denomination * count;
    });
    setState(() {
      totalAmount = total;
      calculateChange();
    });
  }

  /// Menghitung kembalian berdasarkan stok uang
  void calculateChange() {
    double change = totalAmount - grandTotal;
    Map<int, int> changeMap = {};

    if (change > 0) {
      for (var denomination in cashStock.keys.toList()..sort((a, b) => b.compareTo(a))) {
        int count = (change / denomination).floor();
        if (count > 0) {
          int available = cashStock[denomination] ?? 0;
          int used = count > available ? available : count;
          if (used > 0) {
            changeMap[denomination] = used;
            change -= used * denomination;
          }
        }
      }
    }

    setState(() {
      changeDenominations = changeMap;
    });

    print('Remaining Change: $change');
    print('Change Map: $changeMap');
  }


  /// Menambah jumlah lembaran untuk denominasi tertentu
  void incrementDenomination(int denomination) {
    setState(() {
      cashDenominations[denomination] = cashDenominations[denomination]! + 1;
      controllers[denomination]?.text = cashDenominations[denomination].toString();
      calculateTotalCash();
    });
  }

  /// Mengurangi jumlah lembaran untuk denominasi tertentu
  void decrementDenomination(int denomination) {
    if (cashDenominations[denomination]! > 0) {
      setState(() {
        cashDenominations[denomination] = cashDenominations[denomination]! - 1;
        controllers[denomination]?.text = cashDenominations[denomination].toString();
        calculateTotalCash();
      });
    }
  }

  void updateDenominationFromInput(int denomination, String value) {
    setState(() {
      cashDenominations[denomination] = int.tryParse(value) ?? 0;
      calculateTotalCash();
    });
  }

  /// Validasi uang tunai
  void validateCash() {
    if (totalAmount < grandTotal) {
      showDialog(
        context: context,
        barrierDismissible: false, // Dialog tidak bisa ditutup dengan klik di luar
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Insufficient Cash'),
            content: Text(
              'The entered cash amount ${formatRupiah(totalAmount)} is less than the grand total: ${formatRupiah(grandTotal)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    double change = totalAmount - grandTotal;

    // Data yang akan dikirim ke halaman konfirmasi
    final Map<String, dynamic> paymentArguments = {
      'cart': widget.cart,
      'products': widget.products,
      'paymentMethod': 'cash',
      'cashier': displayName,
      'totalAmount': grandTotal, // Pastikan grandTotal dikirim untuk total transaksi
      'cashGiven': totalAmount, // Jumlah uang yang diberikan oleh pengguna
      'change': change, // Selisih kembalian
      'cashDenominations': cashDenominations.map((key, value) => MapEntry(key, value)),
      'changeDenominations': changeDenominations.map((key, value) => MapEntry(key, value)),
    };

    // Jika pembayaran pas (tanpa kembalian)
    if (change == 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Exact Payment'),
            content: const Text('No change needed.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(
                    context,
                    '/confirm-payment',
                    arguments: paymentArguments,
                  );
                },
                child: const Text('Proceed'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Jika pembayaran lebih (dengan kembalian)
    Navigator.pushNamed(
      context,
      '/confirm-payment',
      arguments: paymentArguments,
    );

    print('Navigating to ConfirmPayment with Total Amount: $grandTotal, Cash Given: $totalAmount, Change: $change');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash Payment Input')),
      body: Row(
        children: [
          // Bagian Kiri: Input Uang
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grand Total: ${formatRupiah(grandTotal)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: cashDenominations.entries.map((entry) {
                        final denomination = entry.key;
                        final count = entry.value;
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Text(
                              formatRupiah(denomination.toDouble()),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            title: TextField(
                              controller: controllers[denomination],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter count',
                              ),
                              onChanged: (value) => updateDenominationFromInput(denomination, value),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.red),
                                  onPressed: () => decrementDenomination(denomination),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.green),
                                  onPressed: () => incrementDenomination(denomination),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(color: Colors.grey[300], thickness: 1),
          // Bagian Kanan: Payment Total dan Kembalian
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Total: ${formatRupiah(totalAmount)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Change:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
            child: changeDenominations.isEmpty
                ? Center(child: Text('No change to display'))
                : ListView(
                    children: changeDenominations.entries.map((entry) {
                      return ListTile(
                        title: Text('${entry.value} x ${formatRupiah(entry.key.toDouble())}'),
                      );
                    }).toList(),
                  ),
          ),
        Center(
          child: ElevatedButton(
            onPressed: validateCash,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Payment Summary'),
          ),
        ),
      ],
    ),
  ),
),

        ],
      ),
    );
  }
}
