import 'package:flutter/material.dart';
import '../models/transaction_details_model.dart';
import '../services/transaction_service.dart';
import '../utils/currency_formatter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

//   Future<void> exportReportToPDF(
//     BuildContext context, List<TransactionDetail> details) async {
//   final pdf = pw.Document();

//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a4,
//       build: (pw.Context context) {
//         return pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text(
//               'Sales Report',
//               style: pw.TextStyle(
//                 fontSize: 24,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//             pw.SizedBox(height: 20),
//             pw.Table(
//               border: pw.TableBorder.all(),
//               columnWidths: {
//                 0: pw.FlexColumnWidth(3), // Lebih lebar untuk kolom tanggal
//                 1: pw.FlexColumnWidth(2),
//                 2: pw.FlexColumnWidth(3),
//                 3: pw.FlexColumnWidth(1),
//                 4: pw.FlexColumnWidth(2),
//                 5: pw.FlexColumnWidth(2),
//               },
//               children: [
//                 pw.TableRow(
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.grey300,
//                   ),
//                   children: [
//                     pw.Text('Date', textAlign: pw.TextAlign.center),
//                     pw.Text('Transaction ID', textAlign: pw.TextAlign.center),
//                     pw.Text('Product Name', textAlign: pw.TextAlign.center),
//                     pw.Text('Qty', textAlign: pw.TextAlign.center),
//                     pw.Text('Price', textAlign: pw.TextAlign.center),
//                     pw.Text('Subtotal', textAlign: pw.TextAlign.center),
//                   ].map((e) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: e)).toList(),
//                 ),
//                 ...details.map((detail) {
//                   return pw.TableRow(
//                     children: [
//                       pw.Text(
//                         detail.transaction.createdAt.toString(),
//                         textAlign: pw.TextAlign.center,
//                       ),
//                       pw.Text(
//                         detail.transactionId,
//                         textAlign: pw.TextAlign.center,
//                       ),
//                       pw.Text(
//                         detail.productName,
//                         textAlign: pw.TextAlign.center,
//                       ),
//                       pw.Text(
//                         detail.quantity.toString(),
//                         textAlign: pw.TextAlign.center,
//                       ),
//                       pw.Text(
//                         formatRupiah(detail.price),
//                         textAlign: pw.TextAlign.center,
//                       ),
//                       pw.Text(
//                         formatRupiah(detail.subtotal),
//                         textAlign: pw.TextAlign.center,
//                       ),
//                     ].map((e) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: e)).toList(),
//                   );
//                 }).toList(),
//               ],
//             ),
//           ],
//         );
//       },
//     ),
//   );

//   // Menampilkan dialog untuk mencetak atau menyimpan PDF
//   await Printing.layoutPdf(
//     onLayout: (PdfPageFormat format) async => pdf.save(),
//   );
// }

Future<void> saveReportAsPDF(List<TransactionDetail> details) async {
  final pdf = pw.Document();

  // Buat halaman PDF
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Sales Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(1),
                4: pw.FlexColumnWidth(1),
                5: pw.FlexColumnWidth(1),
                6: pw.FlexColumnWidth(1),
                // 5: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  children: [
                    pw.Text('Date'),
                    pw.Text('Transaction ID'),
                    pw.Text('Product Name'),
                    pw.Text('Qty'),
                    // pw.Text('Price'),
                    pw.Text('Payment Method'),
                    // pw.Text('Subtotal'),
                    pw.Text('Cashier'),
                  ].map((e) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: e)).toList(),
                ),
                ...details.map((detail) {
                  return pw.TableRow(
                    children: [
                      pw.Text(detail.transaction.createdAt.toString()),
                      pw.Text(detail.transactionId),
                      pw.Text(detail.productName),
                      pw.Text(detail.quantity.toString()),
                      // pw.Text(detail.price.toString()),
                      pw.Text(detail.transaction.paymentMethod),
                      // pw.Text(detail.subtotal.toString()),
                      pw.Text(detail.transaction.cashier),
                    ].map((e) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: e)).toList(),
                  );
                }).toList(),
              ],
            ),
          ],
        );
      },
    ),
  );

  // Simpan PDF ke perangkat
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sales_report.pdf');
    await file.writeAsBytes(await pdf.save());
    print('File berhasil disimpan di ${file.path}');
  } catch (e) {
    print('Error menyimpan file PDF: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Section
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: buildDropdown(
                          label: "Cashier",
                          value: selectedCashier,
                          items: transactionDetails
                              .map((e) => e.transaction.cashier)
                              .toSet()
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCashier = value;
                              applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8), // Spasi antar dropdown
                      Expanded(
                        child: buildDropdown(
                          label: "Payment Method",
                          value: selectedPaymentMethod,
                          items: transactionDetails
                              .map((e) => e.transaction.paymentMethod)
                              .toSet()
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value;
                              applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8), // Spasi antar dropdown
                      Expanded(
                        child: buildDropdown(
                          label: "Product",
                          value: selectedProduct,
                          items: transactionDetails
                              .map((e) => e.productName)
                              .toSet()
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
                // Data Table Section
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortColumnIndex: sortColumnIndex,
                      sortAscending: isAscending,
                      columns: [
                        DataColumn(
                          label: const Text('Date'),
                          onSort: (index, ascending) {
                            setState(() {
                              sortColumnIndex = index;
                              isAscending = ascending;
                              filteredDetails.sort((a, b) => compare(
                                  ascending,
                                  a.transaction.createdAt,
                                  b.transaction.createdAt));
                            });
                          },
                        ),
                        const DataColumn(label: Text('Transaction ID')),
                        const DataColumn(label: Text('Product Name')),
                        const DataColumn(label: Text('Quantity')),
                        const DataColumn(label: Text('Price')),
                        const DataColumn(label: Text('Subtotal')),
                        const DataColumn(label: Text('Payment Method')),
                        const DataColumn(label: Text('Cashier')),
                      ],
                      rows: filteredDetails.map((detail) {
                        return DataRow(cells: [
                          DataCell(Text(
                              detail.transaction.createdAt.toString())),
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
                // Export Button
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await saveReportAsPDF(filteredDetails);
                      // await exportReportToPDF(context, filteredDetails);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PDF berhasil disimpan!')),
                      );
                    },
                    icon: const Icon(Icons.file_download),
                    label: const Text("Export Report"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: [
          const DropdownMenuItem(
            value: 'No Filter',
            child: Text('No Filter'),
          ),
          ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  int compare<T extends Comparable?>(bool ascending, T? a, T? b) {
    if (a == null && b == null) return 0;
    if (a == null) return ascending ? -1 : 1;
    if (b == null) return ascending ? 1 : -1;
    return ascending ? a.compareTo(b) : b.compareTo(a);
  }

}
