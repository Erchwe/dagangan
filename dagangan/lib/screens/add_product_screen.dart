import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const AddProductScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ProductService _productService = ProductService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Fungsi untuk menambahkan produk baru
  Future<void> _addProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      final newProduct = Product(
        id: '', // UUID biasanya dibuat di backend
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        stock: int.tryParse(_stockController.text.trim()) ?? 0,
        categoryId: widget.categoryId,
        description: _descriptionController.text.trim(),
      );

      try {
        await _productService.addProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product added successfully'),
            backgroundColor: Theme.of(context).colorScheme.secondary, // Warna dinamis
          ),
        );
        Navigator.pop(context); // Kembali ke halaman produk
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: $e'),
            backgroundColor: Theme.of(context).colorScheme.error, // Warna dinamis
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: colorScheme.primary, // Warna dinamis
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.secondary, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter product name' : null,
                ),
                const SizedBox(height: 12),

                // Price
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.secondary, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter price' : null,
                ),
                const SizedBox(height: 12),

                // Stock
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.secondary, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter stock quantity' : null,
                ),
                const SizedBox(height: 12),

                // Category (Non-editable Field)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  controller: TextEditingController(text: widget.categoryName),
                  enabled: false,
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 12),

                // Product Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Product Description',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.secondary, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _addProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary, // Warna dinamis
                      foregroundColor: colorScheme.onPrimary, // Warna teks dinamis
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                          )
                        : const Text(
                            'Add Product',
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
      ),
    );
  }
}
