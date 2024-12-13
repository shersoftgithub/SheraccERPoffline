import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/models/paymant_model.dart';
import 'package:sheraaccerpoff/models/sgraccoffmodel.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/databaseHelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';


class PaymentFormProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper(); 
  PaymentFormModel? _paymentData; 
  
  PaymentFormModel? get paymentData => _paymentData;
  Future<void> insertPaymentData(PaymentFormModel data) async {
    try {
      final id = await _dbHelper.insertPaymentForm(data); 
      _paymentData = data; 
      notifyListeners(); 
    } catch (e) {
        print("Error inserting data: $e");
      throw Exception("Error inserting data: $e");
    }
  }

   Future<void> insertSupplier(SupplierModel supplier) async {
    try {
      await _dbHelper.insertSupplier(supplier);
      notifyListeners(); 
    } catch (e) {
      print("Error inserting supplier: $e");
      throw Exception("Error inserting supplier: $e");
    }
  }

  Future<List<SupplierModel>> getSuppliers() async {
    try {
      return await _dbHelper.getSuppliers();
    } catch (e) {
      print("Error fetching suppliers: $e");
      return [];
    }
  }
}



