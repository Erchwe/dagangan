import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final supabase = Supabase.instance.client;

  Future<List<TransactionModel>> fetchTransactions() async {
    final response = await supabase.from('transactions').select('*').order('created_at', ascending: false);

    return response.map<TransactionModel>((json) => TransactionModel.fromJson(json)).toList();
  }
}
