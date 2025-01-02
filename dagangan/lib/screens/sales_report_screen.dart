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
  List<TransactionDetail> filteredDetails = [];
  bool isLoading = true;
  int? sortColumnIndex;
  bool isAscending = true;

  String? selectedCashier;
  String? selectedPaymentMethod;
  String? selectedProduct;

  @override
  void initState() {
    super.initState();
    fetchTransactionDetails();
  }

  Future<void> fetchTransactionDetails() async {
    final data = await _transactionService.fetchTransactionDetails();
    setState(() {
      transactionDetails = data;
      filteredDetails = data;
      isLoading = false;
    });
  }

  void onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;

      if (columnIndex == 0) {
        filteredDetails.sort((a, b) =>
            compare(ascending, a.transaction.createdAt, b.transaction.createdAt));
      } else if (columnIndex == 1) {
        filteredDetails.sort(
            (a, b) => compare(ascending, a.transactionId, b.transactionId));
      } else if (columnIndex == 2) {
        filteredDetails.sort(
            (a, b) => compare(ascending, a.productName, b.productName));
      } else if (columnIndex == 3) {
        filteredDetails.sort(
            (a, b) => compare(ascending, a.quantity, b.quantity));
      } else if (columnIndex == 4) {
        filteredDetails.sort((a, b) => compare(ascending, a.price, b.price));
      } else if (columnIndex == 5) {
        filteredDetails.sort(
            (a, b) => compare(ascending, a.subtotal, b.subtotal));
      }
    });
  }

  int compare<T extends Comparable>(bool ascending, T value1, T value2) {
    if (ascending) {
      return value1.compareTo(value2);
    } else {
      return value2.compareTo(value1);
    }
  }

  void applyFilters() {
    setState(() {
      filteredDetails = transactionDetails.where((detail) {
        final cashierMatch = selectedCashier == null ||
            selectedCashier == 'No Filter' ||
            detail.transaction.cashier == selectedCashier;
        final paymentMethodMatch = selectedPaymentMethod == null ||
            selectedPaymentMethod == 'No Filter' ||
            detail.transaction.paymentMethod == selectedPaymentMethod;
        final productMatch = selectedProduct == null ||
            selectedProduct == 'No Filter' ||
            detail.productName == selectedProduct;

        return cashierMatch && paymentMethodMatch && productMatch;
      }).toList();
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
                  child: Wrap(
                    spacing: 8.0, 
                    runSpacing: 8.0, 
                    children: [
                      SizedBox(
                        width: 200, 
                        child: DropdownButtonFormField<String>(
                          isExpanded: true, 
                          decoration: const InputDecoration(
                            labelText: 'Filter by Cashier',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedCashier,
                          items: [
                                const DropdownMenuItem(
                                  value: 'No Filter',
                                  child: Text('No Filter'),
                                )
                              ] +
                              transactionDetails
                                  .map((detail) => detail.transaction.cashier)
                                  .toSet()
                                  .map((cashier) => DropdownMenuItem(
                                        value: cashier,
                                        child: Text(cashier),
                                      ))
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCashier = value;
                              applyFilters();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 200, 
                        child: DropdownButtonFormField<String>(
                          isExpanded: true, 
                          decoration: const InputDecoration(
                            labelText: 'Filter by Payment Method',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedPaymentMethod,
                          items: [
                                const DropdownMenuItem(
                                  value: 'No Filter',
                                  child: Text('No Filter'),
                                )
                              ] +
                              transactionDetails
                                  .map((detail) => detail.transaction.paymentMethod)
                                  .toSet()
                                  .map((method) => DropdownMenuItem(
                                        value: method,
                                        child: Text(method),
                                      ))
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value;
                              applyFilters();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 200, 
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Product',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedProduct,
                          items: [
                                const DropdownMenuItem(
                                  value: 'No Filter',
                                  child: Text('No Filter'),
                                )
                              ] +
                              transactionDetails
                                  .map((detail) => detail.productName)
                                  .toSet()
                                  .map((product) => DropdownMenuItem(
                                        value: product,
                                        child: Text(product),
                                      ))
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedProduct = value;
                              applyFilters();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortColumnIndex: sortColumnIndex,
                      sortAscending: isAscending,
                      columns: [
                        DataColumn(
                          label: const Text('Date'),
                          onSort: (index, ascending) =>
                              onSort(index, ascending),
                        ),
                        DataColumn(
                          label: const Text('Transaction ID'),
                          onSort: (index, ascending) =>
                              onSort(index, ascending),
                        ),
                        DataColumn(
                          label: const Text('Product Name'),
                          onSort: (index, ascending) =>
                              onSort(index, ascending),
                        ),
                        DataColumn(
                          label: const Text('Quantity'),
                          onSort: (index, ascending) =>
                              onSort(index, ascending),
                        ),
                        DataColumn(
                          label: const Text('Price'),
                          onSort: (index, ascending) =>
                              onSort(index, ascending),
                        ),
                        DataColumn(
                          label: const Text('Subtotal'),
                          onSort: (index, ascending) =>
                              onSort(index, ascending),
                        ),
                        DataColumn(label: const Text('Payment Method')),
                        DataColumn(label: const Text('Cashier')),
                      ],
                      rows: filteredDetails.map((detail) {
                        return DataRow(cells: [
                          DataCell(Text(detail.transaction.createdAt
                              .toLocal()
                              .toString())),
                          DataCell(Text(detail.transactionId)),
                          DataCell(Text(detail.productName)),
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
