import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  String? selectedCategoryId;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    descController = TextEditingController(text: widget.product.description);
    priceController = TextEditingController(text: widget.product.price.toString());
    stockController = TextEditingController(text: widget.product.stock.toString());
    selectedCategoryId = widget.product.categoryId;

    loadCategories();
  }

  void loadCategories() async {
    final data = await _categoryService.fetchCategories();
    setState(() {
      categories = data;
    });
  }

  void saveChanges() async {
    try {
      final updatedProduct = Product(
        id: widget.product.id,
        name: nameController.text,
        price: double.parse(priceController.text),
        stock: int.parse(stockController.text),
        categoryId: selectedCategoryId ?? widget.product.categoryId,
        description: descController.text,
      );

      await _productService.updateProduct(updatedProduct);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product updated successfully'),
          backgroundColor: Theme.of(context).colorScheme.secondary, // Warna dinamis
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update product: $e'),
          backgroundColor: Theme.of(context).colorScheme.error, // Warna dinamis
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: colorScheme.primary, // Warna dinamis
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
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
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
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
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
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
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
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
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Select Category',
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
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary, // Warna dinamis
                  foregroundColor: colorScheme.onPrimary, // Warna teks dinamis
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }
}
