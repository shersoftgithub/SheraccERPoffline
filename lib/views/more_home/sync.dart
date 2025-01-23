// import 'package:flutter/material.dart';
// import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
// import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LedgerAtransactionDB.dart';
// import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';

// class SyncButtonPage extends StatelessWidget {
//   // This is the function that will be called when the button is clicked
//   Future<void> syncData() async {
//     // This function calls the method to insert data from LedgerNames and Account_Transactions into ledger_table
//     await LedgerTransactionsDatabaseHelper.instance.insertLedgerDataIntoLedgerTable();
//     print('Data synchronization complete.');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Sync Data")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             // When the button is pressed, the syncData method is called
//             await syncData();
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               content: Text('Data synchronized successfully!'),
//             ));
//           },
//           child: Text('Sync Ledger Data'),
//         ),
//       ),
//     );
//   }
// }