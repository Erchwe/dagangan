import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cash_denomination.dart';

class CashService {
  final supabase = Supabase.instance.client;

  /// Mengambil daftar lembaran uang dari database
  Future<List<CashDenomination>> fetchCashDenominations() async {
    final response = await supabase.from('cash').select('*');
    return response.map<CashDenomination>((e) => CashDenomination.fromJson(e)).toList();
  }

  /// Memperbarui jumlah lembaran uang di kasir
  Future<void> updateCashDenomination(int id, int quantity) async {
    await supabase.from('cash').update({'quantity': quantity}).eq('id', id);
  }
}
