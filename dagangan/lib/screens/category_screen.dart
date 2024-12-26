import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import 'product_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService _categoryService = CategoryService();
  List<Category> categories = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    final data = await _categoryService.fetchCategories();
    setState(() {
      categories = data;
    });
  }

  /// New cat modal
  void _showAddCategoryModal() {
    _nameController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'New Category',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'New Category Name',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6), 
                      borderSide: BorderSide(color: Colors.grey.shade500, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category name cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade500, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await _addCategory();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Fungsi untuk menambahkan kategori ke database
  Future<void> _addCategory() async {
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isNotEmpty) {
      try {
        await _categoryService.addCategory(name, description);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New category added'),
            backgroundColor: Colors.green,
          ),
        );
        loadCategories();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan kategori: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Column (sesuai width)
    int crossAxisCount = screenWidth > 1200
        ? 4
        : screenWidth > 800
            ? 3
            : 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return HoverableCard(
              title: category.name,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryModal,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(
          Icons.add,
          color: Colors.white, 
        ),
        label: const Text(
          'Add Category',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Widget Card (interaction animation)
class HoverableCard extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const HoverableCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isClicked = true),
        onTapUp: (_) {
          setState(() => _isClicked = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isClicked = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isClicked
                ? Colors.deepPurple[300]
                : _isHovered
                    ? Colors.deepPurple[100]
                    : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
              )
            ],
          ),
          child: Center(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isHovered ? Colors.deepPurple : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
