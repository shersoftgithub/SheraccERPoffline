import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

Future<String> createCsvFile(List<Map<String, dynamic>> data) async {
  List<List<dynamic>> rows = [];

  // Adding headers
  rows.add([
    'ID', 'Ledger Name', 'Under', 'Address', 'Contact', 'Mail', 'Tax No', 'Price Level', 'Balance', 'Opening Balance', 'Received Balance', 'Pay Amount', 'Date'
  ]);

  // Adding data rows
  for (var row in data) {
    rows.add([
      row['id'], row['ledger_name'], row['under'], row['address'], row['contact'],
      row['mail'], row['tax_no'], row['price_level'], row['balance'], 
      row['opening_balance'], row['received_balance'], row['pay_amount'], row['date']
    ]);
  }

  // Get the application directory
  final directory = await getApplicationDocumentsDirectory();
  String path = '${directory.path}/ledger_data.csv';

  // Create the file
  File file = File(path);

  // Convert data to CSV and write to file
  String csvData = const ListToCsvConverter().convert(rows);
  await file.writeAsString(csvData);

  return path;
}
