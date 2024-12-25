import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryService {
  final supabase = Supabase.instance.client;

  Future<List<Category>> fetchCategories() async {
    final response = await supabase.from('categories').select('*');
    return response.map<Category>((e) => Category.fromJson(e)).toList();
  }

  Future<void> addCategory(String name, String imageUrl) async {
    await supabase.from('categories').insert({'name': name, 'image_url': imageUrl});
  }

  Future<void> updateCategory(String id, String name, String imageUrl) async {
    await supabase.from('categories').update({'name': name, 'image_url': imageUrl}).eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await supabase.from('categories').delete().eq('id', id);
  }
}
