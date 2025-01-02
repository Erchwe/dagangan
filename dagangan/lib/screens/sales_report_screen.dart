import 'package:flutter/material.dart';
import '../models/transaction_details_model.dart';
import '../services/transaction_service.dart';
import '../utils/currency_formatter.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionDetail> transactionDetails = [];
  bool isLoading = true;
  String filterQuery = '';

  @override
  void initState() {
    super.initState();
    fetchTransactionDetails();
  }

  Future<void> fetchTransactionDetails() async {
    final data = await _transactionService.fetchTransactionDetails();
    setState(() {
      transactionDetails = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Filter by Payment Method',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filterQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
  columns: const [
    DataColumn(label: Text('Date')),
    DataColumn(label: Text('Transaction ID')),
    DataColumn(label: Text('Product Name')), // Ubah kolom menjadi nama produk
    DataColumn(label: Text('Quantity')),
    DataColumn(label: Text('Price')),
    DataColumn(label: Text('Subtotal')),
    DataColumn(label: Text('Payment Method')),
    DataColumn(label: Text('Cashier')),
  ],
  rows: transactionDetails.map((detail) {
    return DataRow(cells: [
      DataCell(Text(detail.transaction.createdAt.toLocal().toString())),
      DataCell(Text(detail.transactionId)),
      DataCell(Text(detail.productName)), // Tampilkan nama produk
      DataCell(Text(detail.quantity.toString())),
      DataCell(Text(formatRupiah(detail.price))),
      DataCell(Text(formatRupiah(detail.subtotal))),
      DataCell(Text(detail.transaction.paymentMethod)),
      DataCell(Text(detail.transaction.cashier)),
    ]);
  }).toList(),
),

                  ),
                ),
              ],
            ),
    );
  }
}
