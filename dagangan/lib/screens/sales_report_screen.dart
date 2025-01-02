import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';
import '../utils/currency_formatter.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> transactions = [];
  bool isLoading = true;
  String filterQuery = '';
  bool isAscending = true;
  String sortBy = 'createdAt';

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final data = await _transactionService.fetchTransactions();
    setState(() {
      transactions = data;
      isLoading = false;
    });
  }

  void sortTransactions(String column) {
    setState(() {
      sortBy = column;
      isAscending = !isAscending;

      transactions.sort((a, b) {
        final dynamic valueA = column == 'totalAmount' ? a.totalAmount : a.createdAt;
        final dynamic valueB = column == 'totalAmount' ? b.totalAmount : b.createdAt;

        return isAscending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
      });
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
                  child: DataTable(
                    sortAscending: isAscending,
                    sortColumnIndex: sortBy == 'createdAt' ? 0 : 1,
                    columns: [
                      DataColumn(
                        label: const Text('Date'),
                        onSort: (_, __) => sortTransactions('createdAt'),
                      ),
                      DataColumn(
                        label: const Text('Total Amount'),
                        onSort: (_, __) => sortTransactions('totalAmount'),
                      ),
                      DataColumn(label: const Text('Payment Method')),
                    ],
                    rows: transactions
                        .where((transaction) => transaction.paymentMethod.toLowerCase().contains(filterQuery))
                        .map((transaction) => DataRow(
                              cells: [
                                DataCell(Text(transaction.createdAt.toLocal().toString())),
                                DataCell(Text(formatRupiah(transaction.totalAmount))),
                                DataCell(Text(transaction.paymentMethod)),
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
