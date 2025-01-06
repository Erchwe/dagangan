import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_details_model.dart';

class TransactionService {
  final supabase = Supabase.instance.client;
    
Future<List<TransactionDetail>> fetchTransactionDetails() async {
  final response = await supabase
      .from('transaction_details')
      .select('''
        *,
        transactions:transaction_details_transaction_id_fkey(created_at, cashier, payment_method),
        products:product_id(name)
      ''');
  return response.map<TransactionDetail>((json) {
    return TransactionDetail.fromJson(json);
  }).toList();
}

}
