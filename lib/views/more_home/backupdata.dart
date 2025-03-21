import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/companydb.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/reciept_databasehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_info2.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_information.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_refer.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:xml/xml.dart' as xml;

class Backupdata extends StatefulWidget {
  const Backupdata({super.key});

  @override
  State<Backupdata> createState() => _BackupdataState();
}

class _BackupdataState extends State<Backupdata> {
  final connection = MssqlConnection.getInstance();
 Future<List<Map<String, dynamic>>> fetchDataFromMSSQL() async {
  try {
    final query = 'SELECT * FROM Stock';
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      try {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          print('Unexpected JSON format: $decodedData');
          return [];
        }
      } catch (e) {
        print('JSON decoding error: $e');
        return [];
      }
    }
    
    print('Unexpected data format for Stock: $rawData');
    return [];
  } catch (e) {
    print('Error fetching data from Stock: $e');
    return [];
  }
}


  // Future<List<Map<String, dynamic>>> fetchDataFromMSSQLStock() async {
  //   try {
  //     final query = 'SELECT * FROM Stock';
  //     final rawData = await MsSQLConnectionPlatform.instance.getData(query);

  //     if (rawData is String) {
  //       final decodedData = jsonDecode(rawData);
  //       if (decodedData is List) {
  //         return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
  //       } else {
  //         throw Exception('Unexpected JSON format for Stock data: $decodedData');
  //       }
  //     }
  //     throw Exception('Unexpected data format for Stock: $rawData');
  //   } catch (e) {
  //     print('Error fetching data from Stock: $e');
  //     rethrow;
  //   }
  // }

Future<List<Map<String, dynamic>>> fetchProductDataFromMSSQL() async {
   try {
      final query = 'SELECT  itemcode,hsncode,itemname,Catagory_id,unit_id,taxgroup_id,tax,cgst,sgst,igst,cess,cessper,adcessper,mrp,retail,wsrate,sprate,branch,stockvaluation,typeofsupply,RegItemName,StockQty,TaxGroup_Name,IsWarranty,TotalWarrantyMonth,ReplaceWarrantyMonth,ProRataWarrantyMonth,prSupplier,isInventory,ItemGroup1,ItemGroup2,ItemGroup3,ItemGroup4,ItemGroup5,Series_Id,isMOP FROM Product_Registration';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for Product_Registration data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for Product_Registration: $rawData');
    } catch (e) {
      print('Error fetching data from Product_Registration: $e');
      rethrow;
    }
}

Future<List<Map<String, dynamic>>> fetchDataFromMSSQLCompany() async {
    try {
final query = '''
  SELECT Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state, 
         Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location, 
         OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate, 
         SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount 
  FROM LedgerNames 
  ORDER BY Ledcode ASC
''';      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    
      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for LedgerNames data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for LedgerNames: $rawData');
    } catch (e) {
      print('Error fetching data from LedgerNames: $e');
      rethrow;
    }
  }

Future<List<Map<String, dynamic>>> fetch_P_vPerticularsDataFromMSSQL() async {
   try {
      final query = 'SELECT  auto,EntryNo,Name,Amount,Discount,Total,Narration,ddate,FyID,FrmID FROM PV_Particulars';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for PV_Particulars data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for PV_Particulars: $rawData');
    } catch (e) {
      print('Error fetching data from PV_Particulars: $e');
      rethrow;
    }
}

Future<List<Map<String, dynamic>>> fetch_R_vPerticularsDataFromMSSQL() async {
   try {
      final query = 'SELECT  auto,EntryNo,Name,Amount,Discount,Total,Narration,ddate,FyID,FrmID FROM RV_Particulars';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for RV_Particulars data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for RV_Particulars: $rawData');
    } catch (e) {
      print('Error fetching data from RV_Particulars: $e');
      rethrow;
    }
}

Future<List<Map<String, dynamic>>> fetch_sale_informationDataFromMSSQL() async {
   try {
      final query = 'SELECT  RealEntryNo,InvoiceNo,DDate,Customer,Toname,Discount,NetAmount,Total,TotalQty FROM Sales_Information';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for RV_Particulars data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for RV_Particulars: $rawData');
    } catch (e) {
      print('Error fetching data from RV_Particulars: $e');
      rethrow;
    }
}
Future<List<Map<String, dynamic>>> fetch_sales_particularsDataFromMSSQL() async {
  try {
    final query = '''
      SELECT 
        DDate, EntryNo, UniqueCode, ItemID, serialno, Rate, RealRate, Qty, freeQty, 
        GrossValue, DiscPersent, Disc, RDisc, Net, Vat, freeVat, cess, Total, Profit, 
        Auto, Unit, UnitValue, Funit, FValue, commision, GridID, takeprintstatus, 
        QtyDiscPercent, QtyDiscount, ScheemDiscPercent, ScheemDiscount, CGST, SGST, 
        IGST, adcess, netdisc, taxrate, SalesmanId, Fcess, Prate, Rprate, location, 
        Stype, LC, ScanBarcode, Remark, FyID, Supplier, Retail, spretail, wsrate
      FROM Sales_Particulars
    ''';

    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);
      if (decodedData is List) {
        return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
      } else {
        throw Exception('Unexpected JSON format for Sales_Particulars data: $decodedData');
      }
    }
    throw Exception('Unexpected data format for Sales_Particulars: $rawData');
  } catch (e) {
    print('Error fetching data from Sales_Particulars: $e');
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> fetch_sale_information22DataFromMSSQL() async {
  try {
    final query = '''
      SELECT RealEntryNo, EntryNo, InvoiceNo, DDate, BTime, Customer, Add1, Add2, Toname, TaxType, 
             GrossValue, Discount, NetAmount, cess, Total, loadingcharge, OtherCharges, OtherDiscount, 
             Roundoff, GrandTotal, SalesAccount, SalesMan, Location, Narration, Profit, CashReceived, 
             BalanceAmount, Ecommision, labourCharge, OtherAmount, Type, PrintStatus, CNo, CreditPeriod, 
             DiscPercent, SType, VatEntryNo, tcommision, commisiontype, cardno, takeuser, PurchaseOrderNo, 
             ddate1, deliverNoteNo, despatchno, despatchdate, Transport, Destination, Transfer_Status, 
             TenderCash, TenderBalance, returnno, returnamt, vatentryname, otherdisc1, salesorderno, 
             systemno, deliverydate, QtyDiscount, ScheemDiscount, Add3, Add4, BankName, CCardNo, 
             SMInvoice, Bankcharges, CGST, SGST, IGST, mrptotal, adcess, BillType, discuntamount, 
             unitprice, lrno, evehicleno, ewaybillno, RDisc, subsidy, kms, todevice, Fcess, spercent, 
             bankamount, FcessType, receiptAmount, receiptDate, JobCardno, WareHouse, CostCenter, 
             CounterClose, CashAccountID, ShippingName, ShippingAdd1, ShippingAdd2, ShippingAdd3, 
             ShippingGstNo, ShippingState, ShippingStateCode, RateType, EmiAc, EmiAmount, EmiRefNo, 
             RedeemPoint, IRNNo, signedinvno, signedQrCode, Salesman1, TCSPer, TCS, app, TotalQty, 
             InvoiceLetter, AckDate, AckNo, Project, PlaceofSupply, tenderRefNo, IsCancel, FyID, 
             m_invoiceno, PaymentTerms, WarrentyTerms, QuotationEntryNo, CreditNoteNo, CreditNoteAmount, 
             Careoff, CareoffAmount, DeliveryStatus, SOrderBilled, isCashCounter, Discountbarcode, 
             ExcEntryNo, ExcEntryAmt, FxCurrency, FxValue, CntryofOrgin, ContryFinalDest, PrecarriageBy, 
             PlacePrecarrier, PortofLoading, Portofdischarge, FinalDestination, CtnNo, Totalctn, Netwt, 
             grosswt, Blno
      FROM Sales_Information
    ''';
    
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);
    if (rawData is String) {
      final decodedData = jsonDecode(rawData);
      if (decodedData is List) {
        return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
      } else {
        throw Exception('Unexpected JSON format for Sales_Information data: $decodedData');
      }
    }
    throw Exception('Unexpected data format for Sales_Information: $rawData');
  } catch (e) {
    print('Error fetching data from Sales_Information: $e');
    rethrow;
  }
}
Future<List<Map<String, dynamic>>> fetch_P_vInformationsDataFromMSSQL() async {
    try {
      final query = 'SELECT RealEntryNo, DDATE, AMOUNT, Discount, Total, CreditAccount, takeuser, Location,Project,SalesMan,MonthDate,app,Transfer_Status,FyID,EntryNo,FrmID,pviCurrency,pviCurrencyValue,pdate FROM PV_Information';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for PV_Particulars data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for PV_Particulars: $rawData');
    } catch (e) {
      print('Error fetching data from PV_Particulars: $e');
      rethrow;
    }
  }

Future<List<Map<String, dynamic>>> fetch_CashAccDataFromMSSQL() async {
   try {
 String query = '''
    SELECT ledcode, LedName
    FROM LedgerNames l
    INNER JOIN LedgerHeads lh ON l.lh_id = lh.lh_id
    WHERE lh_name IN ('BANK A/C', 'CASH IN HAND', 'BANK O/D (LOAN)')
    ORDER BY LedName
    ''';
          final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for RV_Particulars data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for RV_Particulars: $rawData');
    } catch (e) {
      print('Error fetching data from RV_Particulars: $e');
      rethrow;
    }
}

  Future<List<Map<String, dynamic>>> fetch_R_vInformationsDataFromMSSQL() async {
    try {
      final query = 'SELECT RealEntryNo, DDATE, AMOUNT, Discount, Total, DEBITACCOUNT, takeuser, Location,Project,SalesMan,MonthDate,app,Transfer_Status,FyID,EntryNo,FrmID,rviCurrency,rviCurrencyValue,pdate FROM RV_Information';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for RV_Particulars data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for RV_Particulars: $rawData');
    } catch (e) {
      print('Error fetching data from RV_Particulars: $e');
      rethrow;
    }
  }
   Future<List<Map<String, dynamic>>> fetchDataUnitFromMSSQL() async {
    try {
      final query = 'SELECT * FROM Unit_Details';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for Unit_Details data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for Unit_Details: $rawData');
    } catch (e) {
      print('Error fetching data from Unit_Details: $e');
      rethrow;
    }
  }
    Future<List<Map<String, dynamic>>> fetchDatafyFromMSSQL() async {
    try {
      final query = 'SELECT Fyid,Frmdate,Todate FROM FinancialYear';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for Unit_Details data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for Unit_Details: $rawData');
    } catch (e) {
      print('Error fetching data from Unit_Details: $e');
      rethrow;
    }
  }

   Future<List<Map<String, dynamic>>> fetchDataLedgerheadsFromMSSQL() async {
    try {
      final query = 'SELECT lh_id,Mlh_id,lh_name,lh_Code FROM LedgerHeads';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for LedgerHeads data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for LedgerHeads: $rawData');
    } catch (e) {
      print('Error fetching data from LedgerHeads: $e');
      rethrow;
    }
  }

 Future<List<Map<String, dynamic>>> fetchDataSettingsFromMSSQL() async {
  try {
    // Updated query to filter only names starting with 'KEY'
    final query = "SELECT Name, Status FROM Settings WHERE Name LIKE 'KEY%'";
    
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);
      if (decodedData is List) {
        return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
      } else {
        throw Exception('Unexpected JSON format for Settings data: $decodedData');
      }
    }
    throw Exception('Unexpected data format for Settings: $rawData');
  } catch (e) {
    print('Error fetching data from Settings: $e');
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> fetchDataSTYPEFromMSSQL() async {
  try {
    final query = "SELECT iD, Name,Type FROM SalesType";
    
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);
      if (decodedData is List) {
        return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
      } else {
        throw Exception('Unexpected JSON format for SalesType data: $decodedData');
      }
    }
    throw Exception('Unexpected data format for SalesType: $rawData');
  } catch (e) {
    print('Error fetching data from SalesType: $e');
    rethrow;
  }
}

 Future<List<Map<String, dynamic>>> fetchDataFormRegistrationFromMSSQL() async {
    try {
      final query = 'SELECT * FROM FormRegistration';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for FormRegistration data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for FormRegistration: $rawData');
    } catch (e) {
      print('Error fetching data from FormRegistration: $e');
      rethrow;
    }
  }
  //    Future<List<Map<String, dynamic>>> fetchDataCompanyFromMSSQL() async {
  //   try {
  //     final query = 'SELECT * FROM Company';
  //     final rawData = await MsSQLConnectionPlatform.instance.getData(query);

  //     if (rawData is String) {
  //       final decodedData = jsonDecode(rawData);
  //       if (decodedData is List) {
  //         return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
  //       } else {
  //         throw Exception('Unexpected JSON format for Company data: $decodedData');
  //       }
  //     }
  //     throw Exception('Unexpected data format for Company: $rawData');
  //   } catch (e) {
  //     print('Error fetching data from Company: $e');
  //     rethrow;
  //   }
  // }
// Future<List<Map<String, dynamic>>> fetchDataFromMSSQLAccTransations() async {
//   try {
//     // Define the query to fetch clean data from the database
//     final query = '''
//       SELECT DISTINCT TOP 499 Auto, atDate, atLedCode, atType, atEntryno, atDebitAmount, 
//              atCreditAmount, atNarration, atOpposite, atSalesEntryno, atSalesType, 
//              atLocation, atChequeNo, atProject, atBankEntry, atInvestor, atFyID, 
//              atFxDebit, atFxCredit 
//       FROM Account_Transactions
//       WHERE Auto IS NOT NULL -- Exclude rows with NULL Auto
//         AND atDebitAmount >= 0 -- Exclude invalid debit amounts
//         AND atCreditAmount >= 0 -- Exclude invalid credit amounts
//         -- Add any additional filters as needed
//       ORDER BY Auto ASC -- Ensure a consistent row order
//     ''';

//     // Fetch raw data from the database
//     final rawData = await MsSQLConnectionPlatform.instance.getData(query);

//     // Check and decode the data
//     if (rawData is String) {
//       final decodedData = jsonDecode(rawData);

//       if (decodedData is List) {
//         // Convert rows to a list of maps
//         final completeData = decodedData
//             .map((row) => Map<String, dynamic>.from(row))
//             .toList();

//         // Remove any duplicates programmatically (if required)
//         final uniqueData = completeData.toSet().toList();

//         print('Fetched ${uniqueData.length} unique rows from Account_Transactions.');
//         return uniqueData;
//       } else {
//         throw Exception(
//             'Unexpected JSON format for Account_Transactions data: $decodedData');
//       }
//     } else {
//       throw Exception('Unexpected data format for Account_Transactions: $rawData');
//     }
//   } catch (e) {
//     print('Error fetching data from Account_Transactions: $e');
//     rethrow;
//   }
// }

















bool _isLoadingLocalBackup = false;
bool _isLoading = false;
bool _isLoading2 = false;
  // Backup both Stock and Product_Registration to local SQLite database
  Future<void> backupToLocalDatabase() async {
    setState(() => _isLoadingLocalBackup = true); // Start loading
    try {

      final CompanyLedgerData = await fetchDataFromMSSQLCompany();
 if (CompanyLedgerData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL Product_Registration')),
        );
        return;
      }
      final DbHelper = LedgerTransactionsDatabaseHelper.instance;
for (var row in CompanyLedgerData) {
  Map<String, dynamic> rowData = {
    'Ledcode': row['Ledcode']?.toString() ?? '', 
    'LedName': row['LedName']?.toString() ?? 'Unknown',
    'lh_id': row['lh_id']?.toString() ?? '',
    'add1': row['add1']?.toString() ?? 'Default Address',
    'add2': row['add2']?.toString() ?? 'Default Address',
    'add3': row['add3']?.toString() ?? 'Default Address',
    'add4': row['add4']?.toString() ?? 'Default Address',
    'city': row['city']?.toString() ?? 'Default City',
    'route': row['route']?.toString() ?? 'Default Route',
    'state': row['state']?.toString() ?? 'Default State',
    'Mobile': row['Mobile']?.toString() ?? '',
    'pan': row['pan']?.toString() ?? '',
    'Email': row['Email']?.toString() ?? '',
    'gstno': row['gstno']?.toString() ?? '',
    'CAmount': row['CAmount'] != null ? row['CAmount'].toString() : '0.0',
    'Active': row['Active'] != null ? row['Active'].toString() : '1',
    'SalesMan': row['SalesMan']?.toString() ?? 'Unknown',
    'Location': row['Location']?.toString() ?? '',
    'OrderDate': row['OrderDate']?.toString() ?? '',
    'DeliveryDate': row['DeliveryDate']?.toString() ?? '',
    'CPerson': row['CPerson']?.toString() ?? 'Unknown',
    'CostCenter': row['CostCenter']?.toString() ?? 'Default Center',
    'Franchisee': row['Franchisee']?.toString() ?? 'Unknown',
    'SalesRate': row['SalesRate']?.toString() ?? '',
    'SubGroup': row['SubGroup']?.toString() ?? 'Unknown SubGroup',
    'SecondName': row['SecondName']?.toString() ?? 'Unknown',
    'UserName': row['UserName']?.toString() ?? 'Unknown',
    'Password': row['Password']?.toString() ?? 'Unknown',
    'CustomerType': row['CustomerType']?.toString() ?? 'Regular',
    'OTP': row['OTP']?.toString() ?? '',
    'maxDiscount': row['maxDiscount'] != null ? row['maxDiscount'].toString() : '0.0',
  };

  await DbHelper.insertLedgerData2(rowData);
  
}

final paymentData = await fetch_P_vPerticularsDataFromMSSQL();
 if (paymentData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL Company data')),
        );
        return;
      }
      final DbHelperpay = LedgerTransactionsDatabaseHelper.instance;
for (var row in paymentData) {
  Map<String, dynamic> rowData = {
    'auto': row['auto']?.toString() ?? '', 
    'EntryNo': row['EntryNo']?.toString() ?? '',
    'Name': row['Name']?.toString() ?? '',
    'Amount': row['Amount']?.toString() ?? '',
    'Discount': row['Discount']?.toString() ?? '',
    'Total': row['Total']?.toString() ?? '',
    'Narration': row['Narration']?.toString() ?? '',
    'ddate': row['ddate']?.toString() ?? '',
    'FyID': row['FyID']?.toString() ?? '',
    'FrmID': row['FrmID']?.toString() ?? '',
  };

  await DbHelperpay.insertPVParticulars2(rowData);
}
final paymentDatainfo = await fetch_P_vInformationsDataFromMSSQL();
 if (paymentDatainfo.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL Pv info')),
        );
        return;
      }
      final DbHelperpayinfo = LedgerTransactionsDatabaseHelper.instance;
for (var row in paymentDatainfo) {
  Map<String, dynamic> rowData = {
    'RealEntryNo': row['RealEntryNo']?.toString() ?? '', 
    'DDATE': row['DDATE']?.toString() ?? '',
    'AMOUNT': row['AMOUNT']?.toString() ?? '',
    'Discount': row['Discount']?.toString() ?? '',
    'Total': row['Total']?.toString() ?? '',
    'CreditAccount': row['CreditAccount']?.toString() ?? '',
    'takeuser': row['takeuser']?.toString() ?? '',
    'Location': row['Location']?.toString() ?? '',
    'Project': row['Project']?.toString() ?? '', 
    'SalesMan': row['SalesMan']?.toString() ?? '',
    'MonthDate': row['MonthDate']?.toString() ?? '',
    'app': row['app']?.toString() ?? '',
    'Transfer_Status': row['Transfer_Status']?.toString() ?? '',
    'FyID': row['FyID']?.toString() ?? '',
    'EntryNo': row['EntryNo']?.toString() ?? '',
    'FrmID': row['FrmID']?.toString() ?? '',
    'pviCurrency': row['pviCurrency']?.toString() ?? '',
    'pviCurrencyValue': row['pviCurrencyValue']?.toString() ?? '',
    'pdate': row['pdate']?.toString() ?? '',
  };
   

  await DbHelperpayinfo.insertPVInformation2(rowData);
}
final recimentData = await fetch_R_vPerticularsDataFromMSSQL();
 if (recimentData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL  Rv perticular')),
        );
        return;
      }
      final DbHelperReci = LedgerTransactionsDatabaseHelper.instance;
for (var row in recimentData) {
  Map<String, dynamic> rowData = {
    'auto': row['auto']?.toString() ?? '', 
     'EntryNo': (row['EntryNo'] is int) 
      ? (row['EntryNo'] as int).toDouble()  
      : (row['EntryNo'] as double?),
    'Name': row['Name']?.toString() ?? '',
    'Amount': row['Amount']?.toString() ?? '',
    'Discount': row['Discount']?.toString() ?? '',
    'Total': row['Total']?.toString() ?? '',
    'Narration': row['Narration']?.toString() ?? '',
    'ddate': row['ddate']?.toString() ?? '',
     'FyID': row['FyID']?.toString() ?? '',
    'FrmID': row['FrmID']?.toString() ?? '',
  };

  await DbHelperReci.insertRVParticulars2(rowData);
}

final recieDatainfo = await fetch_R_vInformationsDataFromMSSQL();
 if (recieDatainfo.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL Rv info')),
        );
        return;
      }
      final DbHelperreciinfo = LedgerTransactionsDatabaseHelper.instance;
for (var row in recieDatainfo) {
  Map<String, dynamic> rowData = {
    'RealEntryNo': row['RealEntryNo']?.toString() ?? '', 
    'DDATE': row['DDATE']?.toString() ?? '',
    'AMOUNT': row['AMOUNT']?.toString() ?? '',
    'Discount': row['Discount']?.toString() ?? '',
    'Total': row['Total']?.toString() ?? '',
    'DEBITACCOUNT': row['DEBITACCOUNT']?.toString() ?? '',
    'takeuser': row['takeuser']?.toString() ?? '',
    'Location': row['Location']?.toString() ?? '',
    'Project': row['Project']?.toString() ?? '', 
    'SalesMan': row['SalesMan']?.toString() ?? '',
    'MonthDate': row['MonthDate']?.toString() ?? '',
    'app': row['app']?.toString() ?? '',
    'Transfer_Status': row['Transfer_Status']?.toString() ?? '',
    'FyID': row['FyID']?.toString() ?? '',
    'EntryNo': row['EntryNo']?.toString() ?? '',
    'FrmID': row['FrmID']?.toString() ?? '',
    'pviCurrency': row['pviCurrency']?.toString() ?? '',
    'pviCurrencyValue': row['pviCurrencyValue']?.toString() ?? '',
    'pdate': row['pdate']?.toString() ?? '',
  };
   

  await DbHelperreciinfo.insertRVInformation2(rowData);
}

final AccData = await fetch_CashAccDataFromMSSQL();
 if (AccData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL cashacc')),
        );
        return;
      }
      final DbHelperAcc = PV_DatabaseHelper.instance;
for (var row in AccData) {
  String accountName = row['LedName']?.toString() ?? ''; // Extracting string

  await DbHelperAcc.insertCaccount(accountName); // Passing string
}

final saleData = await fetch_sale_informationDataFromMSSQL();
 if (saleData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL sale info')),
        );
        return;
      }

final saleDataper = await fetch_sales_particularsDataFromMSSQL();
 if (saleDataper.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL sale perticular')),
        );
        return;
      }
      final DbHelperSaleper = SalesInformationDatabaseHelper2.instance;
for (var row in saleDataper) {
  Map<String, dynamic> rowData = {
   'DDate': row['DDate']?.toString() ?? '',
            'EntryNo': row['EntryNo']?.toString() ?? '',
            'UniqueCode': row['UniqueCode']?.toString() ?? '',
            'ItemID': row['ItemID']?.toString() ?? '',
            'serialno': row['serialno']?.toString() ?? '',
            'Rate': row['Rate']?.toString() ?? '',
            'RealRate': row['RealRate']?.toString() ?? '',
            'Qty': row['Qty']?.toString() ?? '',
            'freeQty': row['freeQty']?.toString() ?? '',
            'GrossValue': row['GrossValue']?.toString() ?? '',
            'DiscPersent': row['DiscPersent']?.toString() ?? '',
            'Disc': row['Disc']?.toString() ?? '',
            'RDisc': row['RDisc']?.toString() ?? '',
            'Net': row['Net']?.toString() ?? '',
            'Vat': row['Vat']?.toString() ?? '',
            'freeVat': row['freeVat']?.toString() ?? '',
            'cess': row['cess']?.toString() ?? '',
            'Total': row['Total']?.toString() ?? '',
            'Profit': row['Profit']?.toString() ?? '',
            'Auto': row['Auto']?.toString() ?? '',
            'Unit': row['Unit']?.toString() ?? '',
            'UnitValue': row['UnitValue']?.toString() ?? '',
            'Funit': row['Funit']?.toString() ?? '',
            'FValue': row['FValue']?.toString() ?? '',
            'commision': row['commision']?.toString() ?? '',
            'GridID': row['GridID']?.toString() ?? '',
            'takeprintstatus': row['takeprintstatus']?.toString() ?? '',
            'QtyDiscPercent': row['QtyDiscPercent']?.toString() ?? '',
            'QtyDiscount': row['QtyDiscount']?.toString() ?? '',
            'ScheemDiscPercent': row['ScheemDiscPercent']?.toString() ?? '',
            'ScheemDiscount': row['ScheemDiscount']?.toString() ?? '',
            'CGST': row['CGST']?.toString() ?? '',
            'SGST': row['SGST']?.toString() ?? '',
            'IGST': row['IGST']?.toString() ?? '',
            'adcess': row['adcess']?.toString() ?? '',
            'netdisc': row['netdisc']?.toString() ?? '',
            'taxrate': row['taxrate']?.toString() ?? '',
            'SalesmanId': row['SalesmanId']?.toString() ?? '',
            'Fcess': row['Fcess']?.toString() ?? '',
            'Prate': row['Prate']?.toString() ?? '',
            'Rprate': row['Rprate']?.toString() ?? '',
            'location': row['location']?.toString() ?? '',
            'Stype': row['Stype']?.toString() ?? '',
            'LC': row['LC']?.toString() ?? '',
            'ScanBarcode': row['ScanBarcode']?.toString() ?? '',
            'Remark': row['Remark']?.toString() ?? '',
            'FyID': row['FyID']?.toString() ?? '',
            'Supplier': row['Supplier']?.toString() ?? '',
            'Retail': row['Retail']?.toString() ?? '',
            'spretail': row['spretail']?.toString() ?? '',
            'wsrate': row['wsrate']?.toString() ?? '',
  };

  await DbHelperSaleper.insertParticular2(rowData);
}

final saleDatainf = await fetch_sale_information22DataFromMSSQL();
 if (saleDatainf.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL saleinfo22')),
        );
        return;
      }
      final DbHelperSaleinf = SalesInformationDatabaseHelper2.instance;
for (var row in saleDatainf) {
  Map<String, dynamic> rowData = {
    'RealEntryNo': row['RealEntryNo']?.toString() ?? '', 
        'EntryNo': row['EntryNo']?.toString() ?? '',
        'InvoiceNo': row['InvoiceNo']?.toString() ?? '',
        'DDate': row['DDate']?.toString() ?? '',
        'BTime': row['BTime']?.toString() ?? '',
        'Customer': row['Customer']?.toString() ?? '',
        'Add1': row['Add1']?.toString() ?? '',
        'Add2': row['Add2']?.toString() ?? '',
        'Toname': row['Toname']?.toString() ?? '',
        'TaxType': row['TaxType']?.toString() ?? '',
        'GrossValue': row['GrossValue']?.toString() ?? '',
        'Discount': row['Discount']?.toString() ?? '',
        'NetAmount': row['NetAmount']?.toString() ?? '',
        'cess': row['cess']?.toString() ?? '',
        'Total': row['Total']?.toString() ?? '',
        'loadingcharge': row['loadingcharge']?.toString() ?? '',
        'OtherCharges': row['OtherCharges']?.toString() ?? '',
        'OtherDiscount': row['OtherDiscount']?.toString() ?? '',
        'Roundoff': row['Roundoff']?.toString() ?? '',
        'GrandTotal': row['GrandTotal']?.toString() ?? '',
        'SalesAccount': row['SalesAccount']?.toString() ?? '',
        'SalesMan': row['SalesMan']?.toString() ?? '',
        'Location': row['Location']?.toString() ?? '',
        'Narration': row['Narration']?.toString() ?? '',
        'Profit': row['Profit']?.toString() ?? '',
        'CashReceived': row['CashReceived']?.toString() ?? '',
        'BalanceAmount': row['BalanceAmount']?.toString() ?? '',
        'Ecommision': row['Ecommision']?.toString() ?? '',
        'labourCharge': row['labourCharge']?.toString() ?? '',
        'OtherAmount': row['OtherAmount']?.toString() ?? '',
        'Type': row['Type']?.toString() ?? '',
        'PrintStatus': row['PrintStatus']?.toString() ?? '',
        'CNo': row['CNo']?.toString() ?? '',
        'CreditPeriod': row['CreditPeriod']?.toString() ?? '',
        'DiscPercent': row['DiscPercent']?.toString() ?? '',
        'SType': row['SType']?.toString() ?? '',
        'VatEntryNo': row['VatEntryNo']?.toString() ?? '',
        'tcommision': row['tcommision']?.toString() ?? '',
        'commisiontype': row['commisiontype']?.toString() ?? '',
        'cardno': row['cardno']?.toString() ?? '',
        'takeuser': row['takeuser']?.toString() ?? '',
        'PurchaseOrderNo': row['PurchaseOrderNo']?.toString() ?? '',
        'ddate1': row['ddate1']?.toString() ?? '',
        'deliverNoteNo': row['deliverNoteNo']?.toString() ?? '',
        'despatchno': row['despatchno']?.toString() ?? '',
        'despatchdate': row['despatchdate']?.toString() ?? '',
        'Transport': row['Transport']?.toString() ?? '',
        'Destination': row['Destination']?.toString() ?? '',
        'Transfer_Status': row['Transfer_Status']?.toString() ?? '',
        'TenderCash': row['TenderCash']?.toString() ?? '',
        'TenderBalance': row['TenderBalance']?.toString() ?? '',
        'returnno': row['returnno']?.toString() ?? '',
        'returnamt': row['returnamt']?.toString() ?? '',
        'vatentryname': row['vatentryname']?.toString() ?? '',
        'otherdisc1': row['otherdisc1']?.toString() ?? '',
        'salesorderno': row['salesorderno']?.toString() ?? '',
        'systemno': row['systemno']?.toString() ?? '',
        'deliverydate': row['deliverydate']?.toString() ?? '',
        'QtyDiscount': row['QtyDiscount']?.toString() ?? '',
        'ScheemDiscount': row['ScheemDiscount']?.toString() ?? '',
        'Add3': row['Add3']?.toString() ?? '',
        'Add4': row['Add4']?.toString() ?? '',
        'BankName': row['BankName']?.toString() ?? '',
        'CCardNo': row['CCardNo']?.toString() ?? '',
        'SMInvoice': row['SMInvoice']?.toString() ?? '',
        'Bankcharges': row['Bankcharges']?.toString() ?? '',
        'CGST': row['CGST']?.toString() ?? '',
        'SGST': row['SGST']?.toString() ?? '',
        'IGST': row['IGST']?.toString() ?? '',
        'mrptotal': row['mrptotal']?.toString() ?? '',
        'adcess': row['adcess']?.toString() ?? '',
        'BillType': row['BillType']?.toString() ?? '',
        'discuntamount': row['discuntamount']?.toString() ?? '',
        'unitprice': row['unitprice']?.toString() ?? '',
        'lrno': row['lrno']?.toString() ?? '',
        'evehicleno': row['evehicleno']?.toString() ?? '',
        'ewaybillno': row['ewaybillno']?.toString() ?? '',
        'RDisc': row['RDisc']?.toString() ?? '',
        'subsidy': row['subsidy']?.toString() ?? '',
        'kms': row['kms']?.toString() ?? '',
        'todevice': row['todevice']?.toString() ?? '',
        'Fcess': row['Fcess']?.toString() ?? '',
        'spercent': row['spercent']?.toString() ?? '',
        'bankamount': row['bankamount']?.toString() ?? '',
        'FcessType': row['FcessType']?.toString() ?? '',
        'receiptAmount': row['receiptAmount']?.toString() ?? '',
        'receiptDate': row['receiptDate']?.toString() ?? '',
        'JobCardno': row['JobCardno']?.toString() ?? '',
        'WareHouse': row['WareHouse']?.toString() ?? '',
        'CostCenter': row['CostCenter']?.toString() ?? '',
        'CounterClose': row['CounterClose']?.toString() ?? '',
        'CashAccountID': row['CashAccountID']?.toString() ?? '',
        'ShippingName': row['ShippingName']?.toString() ?? '',
        'ShippingAdd1': row['ShippingAdd1']?.toString() ?? '',
        'ShippingAdd2': row['ShippingAdd2']?.toString() ?? '',
        'ShippingAdd3': row['ShippingAdd3']?.toString() ?? '',
        'ShippingGstNo': row['ShippingGstNo']?.toString() ?? '',
        'ShippingState': row['ShippingState']?.toString() ?? '',
        'ShippingStateCode': row['ShippingStateCode']?.toString() ?? '',
        'RateType': row['RateType']?.toString() ?? '',
        'EmiAc': row['EmiAc']?.toString() ?? '',
        'EmiAmount': row['EmiAmount']?.toString() ?? '',
        'EmiRefNo': row['EmiRefNo']?.toString() ?? '',
        'RedeemPoint': row['RedeemPoint']?.toString() ?? '',
        'IRNNo': row['IRNNo']?.toString() ?? '',
        'signedinvno': row['signedinvno']?.toString() ?? '',
        'signedQrCode': row['signedQrCode']?.toString() ?? '',
        'Salesman1': row['Salesman1']?.toString() ?? '',
        'TCSPer': row['TCSPer']?.toString() ?? '',
        'TCS': row['TCS']?.toString() ?? '',
        'app': row['app']?.toString() ?? '',
        'TotalQty': row['TotalQty']?.toString() ?? '',
        'InvoiceLetter': row['InvoiceLetter']?.toString() ?? '',
        'AckDate': row['AckDate']?.toString() ?? '',
        'AckNo': row['AckNo']?.toString() ?? '',
        'Project': row['Project']?.toString() ?? '',
        'PlaceofSupply': row['PlaceofSupply']?.toString() ?? '',
        'tenderRefNo': row['tenderRefNo']?.toString() ?? '',
        'IsCancel': row['IsCancel']?.toString() ?? '',
        'FyID': row['FyID']?.toString() ?? '',
        'm_invoiceno': row['m_invoiceno']?.toString() ?? '',
        'PaymentTerms': row['PaymentTerms']?.toString() ?? '',
        'WarrentyTerms': row['WarrentyTerms']?.toString() ?? '',
        'QuotationEntryNo': row['QuotationEntryNo']?.toString() ?? '',
        'CreditNoteNo': row['CreditNoteNo']?.toString() ?? '',
        'CreditNoteAmount': row['CreditNoteAmount']?.toString() ?? '',
        'Careoff': row['Careoff']?.toString() ?? '',
        'CareoffAmount': row['CareoffAmount']?.toString() ?? '',
        'DeliveryStatus': row['DeliveryStatus']?.toString() ?? '',
        'SOrderBilled': row['SOrderBilled']?.toString() ?? '',
        'isCashCounter': row['isCashCounter']?.toString() ?? '',
        'Discountbarcode': row['Discountbarcode']?.toString() ?? '',
        'ExcEntryNo': row['ExcEntryNo']?.toString() ?? '',
        'ExcEntryAmt': row['ExcEntryAmt']?.toString() ?? '',
        'FxCurrency': row['FxCurrency']?.toString() ?? '',
        'FxValue': row['FxValue']?.toString() ?? '',
        'CntryofOrgin': row['CntryofOrgin']?.toString() ?? '',
        'ContryFinalDest': row['ContryFinalDest']?.toString() ?? '',
        'PrecarriageBy': row['PrecarriageBy']?.toString() ?? '',
        'PlacePrecarrier': row['PlacePrecarrier']?.toString() ?? '',
        'PortofLoading': row['PortofLoading']?.toString() ?? '',
        'Portofdischarge': row['Portofdischarge']?.toString() ?? '',
        'FinalDestination': row['FinalDestination']?.toString() ?? '',
        'CtnNo': row['CtnNo']?.toString() ?? '',
        'Totalctn': row['Totalctn']?.toString() ?? '',
        'Netwt': row['Netwt']?.toString() ?? '',
        'grosswt': row['grosswt']?.toString() ?? '',
        'Blno': row['Blno']?.toString() ?? '',
  };

  await DbHelperSaleinf.insertSale2(rowData);
}
// final unitData = await fetchDataUnitFromMSSQL();
//  if (unitData.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('No data fetched from MSSQL unit')),
//         );
//         return;
//       }
//       final DbHelperUnit = SaleReferenceDatabaseHelper.instance;
// for (var row in unitData) {
//   Map<String, dynamic> rowData = {
//     'ItemId': row['ItemId']?.toString() ?? '',  
//       'PUnit': row['PUnit']?.toString() ?? '',
//       'SUnit': row['SUnit']?.toString() ?? '',
//       'Unit': row['Unit']?.toString() ?? '',
//       'Conversion': row['Conversion']?.toString() ?? '0', 
//       'Auto': row['Auto']?.toString() ?? '0',
//       'Rate': row['Rate']?.toString() ?? '0',
//       'Barcode': row['Barcode']?.toString() ?? '',
//       'IsGatePass': row['IsGatePass']?.toString() ?? '0',
//   };

//   await DbHelperUnit.insertunit(rowData);
// }
final fyData = await fetchDatafyFromMSSQL();
 if (fyData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL fy')),
        );
        return;
      }
      final DbHelperfy = SaleReferenceDatabaseHelper.instance;
for (var row in fyData) {
  Map<String, dynamic> rowData = {
    'Fyid': row['Fyid']?.toString() ?? '',  
      'Frmdate': row['Frmdate']?.toString() ?? '',
      'Todate': row['Todate']?.toString() ?? '',
  };
  await DbHelperfy.insertfyid(rowData);
}

final LedheadsData = await fetchDataLedgerheadsFromMSSQL();
 if (LedheadsData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL leadgerheads')),
        );
        return;
      }
      final DbHelperledhead = SaleReferenceDatabaseHelper.instance;
for (var row in LedheadsData) {
  Map<String, dynamic> rowData = {
    'lh_id': row['lh_id']?.toString() ?? '',  
      'Mlh_id': row['Mlh_id']?.toString() ?? '',
      'lh_name': row['lh_name']?.toString() ?? '',
      'lh_Code': row['lh_Code']?.toString() ?? '',
  };
  await DbHelperledhead.insertLedgerheads(rowData);
}

// final settingsData = await fetchDataSettingsFromMSSQL();
//  if (settingsData.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('No data fetched from MSSQL settings')),
//         );
//         return;
//       }
//       final DbHelpersettings = SaleReferenceDatabaseHelper.instance;
// for (var row in settingsData) {
//   Map<String, dynamic> rowData = {
//     'Name': row['Name']?.toString() ?? '',  
//       'Status': row['Status']?.toString() ?? '',
//   };
//   await DbHelpersettings.insertSettings(rowData);
// }

final stypeData = await fetchDataSTYPEFromMSSQL();
 if (stypeData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL stypes')),
        );
        return;
      }
      final DbHelperstype = SaleReferenceDatabaseHelper.instance;
for (var row in stypeData) {
  Map<String, dynamic> rowData = {
      'iD': row['iD']?.toString() ?? '',  
      'Name': row['Name']?.toString() ?? '',
      'Type': row['Type']?.toString() ?? '',
  };
  await DbHelperstype.insertStype(rowData);
}

final FormregData = await fetchDataFormRegistrationFromMSSQL();
 if (FormregData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL formreg')),
        );
        return;
      }
      final DbHelperFormReg = LedgerTransactionsDatabaseHelper.instance;
for (var row in FormregData) {
  Map<String, dynamic> rowData = {
      'fmrEntryNo': row['fmrEntryNo']?.toString() ?? '',  
      'fmrName': row['fmrName']?.toString() ?? '',
      'fmrTypeOfVoucher': row['fmrTypeOfVoucher']?.toString() ?? '',
      'fmrAbbreviation': row['fmrAbbreviation']?.toString() ?? '',
  };
  await DbHelperFormReg.insertFormRegistration(rowData);
}
    final stockData = await fetchDataFromMSSQL();

      if (stockData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL Stock')),
        );
        return;
      }

      final dbHelper = StockDatabaseHelper.instance;
for (var row in stockData) {
  Map<String, dynamic> rowData = {
    'ItemId': row['ItemId']?.toString() ?? '',
    'serialno': row['serialno']?.toString() ?? '',
    'supplier': row['supplier']?.toString() ?? '',
    'Qty': (row['Qty'] is num) ? row['Qty'].toDouble() : 0.0,
    'Disc': (row['Disc'] is num) ? row['Disc'].toDouble() : 0.0,
    'Free': (row['Free'] is num) ? row['Free'].toDouble() : 0.0,
    'Prate': (row['Prate'] is num) ? row['Prate'].toDouble() : 0.0,
    'Amount': (row['Amount'] is num) ? row['Amount'].toDouble() : 0.0,
    'TaxType': row['TaxType']?.toString() ?? '',
    'Category': row['Category']?.toString()?.isNotEmpty == true
        ? row['Category'].toString()
        : 'Uncategorized',
    'SRate': (row['SRate'] is num) ? row['SRate'].toDouble() : 0.0,
    'Mrp': (row['Mrp'] is num) ? row['Mrp'].toDouble() : 0.0,
    'Retail': (row['Retail'] is num) ? row['Retail'].toDouble() : 0.0,
    'SpRetail': (row['SpRetail'] is num) ? row['SpRetail'].toDouble() : 0.0,
    'WsRate': (row['WsRate'] is num) ? row['WsRate'].toDouble() : 0.0,
    'Branch': row['Branch']?.toString() ?? '',
    'RealPrate': (row['RealPrate'] is num) ? row['RealPrate'].toDouble() : 0.0,
    'Location': row['Location']?.toString() ?? '',
    'EstUnique': row['EstUnique']?.toString() ?? 'DefaultEstUnique',
    'Locked': row['Locked']?.toString() ?? '',
    'expDate': row['expDate']?.toString() ?? '',
    'Brand': row['Brand']?.toString() ?? '',
    'Company': row['Company']?.toString() ?? '',
    'Size': row['Size']?.toString() ?? '',
    'Color': row['Color']?.toString() ?? '',
    'obarcode': row['obarcode']?.toString() ?? '',
    'todevice': row['todevice']?.toString() ?? '',
    'Pdate': row['Pdate']?.toString() ?? '',
    'Cbarcode': row['Cbarcode']?.toString() ?? 'Default',
    'SktSales': (row['SktSales'] is int) ? row['SktSales'] : 0,
  };

  try {
    await dbHelper.insertDataStock(rowData);
  } catch (e) {
    print("Error inserting row: $rowData - $e");
  }
}


      final productData1 = await fetchProductDataFromMSSQL();
      if (productData1.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL Product_Registration')),
        );
        return;
      }

      for (var row in productData1) {
        Map<String, dynamic> productRowData = {
          'itemcode': row['itemcode']?.toString(),
          'hsncode': row['hsncode']?.toString(),
          'itemname': row['itemname']?.toString(),
          'Catagory_id': row['Catagory_id']?.toString(),
          // 'Mfr_id': row['Mfr_id']?.toString(),
          //'subcatagory_id': row['subcatagory_id']?.toString(),
          'unit_id': row['unit_id']?.toString(),
          //'rack_id': row['rack_id']?.toString(),
          // 'packing': row['packing']?.toString(),
          //'reorder': (row['reorder'] is int) ? row['reorder'] : 0,
          //'maxorder': (row['maxorder'] is int) ? row['maxorder'] : 0,
          'taxgroup_id': row['taxgroup_id']?.toString(),
          'tax': (row['tax'] is num) ? row['tax'].toDouble() : 0.0,
          'cgst': (row['cgst'] is num) ? row['cgst'].toDouble() : 0.0,
          'sgst': (row['sgst'] is num) ? row['sgst'].toDouble() : 0.0,
          'igst': (row['igst'] is num) ? row['igst'].toDouble() : 0.0,
          'cess': (row['cess'] is num) ? row['cess'].toDouble() : 0.0,
          'cessper': (row['cessper'] is num) ? row['cessper'].toDouble() : 0.0,
          'adcessper': (row['adcessper'] is num) ? row['adcessper'].toDouble() : 0.0,
          'mrp': (row['mrp'] is num) ? row['mrp'].toDouble() : 0.0,
          'retail': (row['retail'] is num) ? row['retail'].toDouble() : 0.0,
          'wsrate': (row['wsrate'] is num) ? row['wsrate'].toDouble() : 0.0,
          'sprate': (row['sprate'] is num) ? row['sprate'].toDouble() : 0.0,
          'branch': row['branch']?.toString(),
          'stockvaluation': row['stockvaluation']?.toString(),
          'typeofsupply': row['typeofsupply']?.toString(),
           //'check_neg': (row['check_neg'] is int) ? row['check_neg'] : 0,
          //'active': (row['active'] is int) ? row['active'] : 1,
         // 'Internationalbarcode': row['Internationalbarcode']?.toString(),
        // 'serialno': row['serialno']?.toString(),
       //  'bom': row['bom']?.toString(),
      //'photo': row['photo']?.toString(),
          'RegItemName': row['RegItemName']?.toString(),
          'StockQty': (row['StockQty'] is num) ? row['StockQty'].toDouble() : 0.0,
          'TaxGroup_Name': row['TaxGroup_Name']?.toString(),
          //'PluNo': row['PluNo']?.toString(),
         // 'MachineItem': row['MachineItem']?.toString(),
        //'PackingItem': row['PackingItem']?.toString(),
       //'SpeedBill': row['SpeedBill']?.toString(),
      // 'Expiry': row['Expiry']?.toString(),
     // 'Brand': row['Brand']?.toString(),
    // 'PcsBox': (row['PcsBox'] is int) ? row['PcsBox'] : 0,
   // 'SqftBox': (row['SqftBox'] is num) ? row['SqftBox'].toDouble() : 0.0,
  // 'LC': row['LC']?.toString(),
          'IsWarranty': (row['IsWarranty'] is int) ? row['IsWarranty'] : 0,
          'TotalWarrantyMonth': (row['TotalWarrantyMonth'] is int) ? row['TotalWarrantyMonth'] : 0,
          'ReplaceWarrantyMonth': (row['ReplaceWarrantyMonth'] is int) ? row['ReplaceWarrantyMonth'] : 0,
          'ProRataWarrantyMonth': (row['ProRataWarrantyMonth'] is int) ? row['ProRataWarrantyMonth'] : 0,
          'prSupplier': row['prSupplier']?.toString()??"",
          'isInventory': (row['isInventory'] is int) ? row['isInventory'] : 1,
          'ItemGroup1': row['ItemGroup1']?.toString(),
          'ItemGroup2': row['ItemGroup2']?.toString(),
          'ItemGroup3': row['ItemGroup3']?.toString(),
          'ItemGroup4': row['ItemGroup4']?.toString(),
          'ItemGroup5': row['ItemGroup5']?.toString(),
           'Series_Id': (row['Series_Id'] is num) ? row['Series_Id'].toDouble() : 0.0,
           'isMOP': (row['isMOP'] is num) ? row['isMOP'].toDouble() : 0.0,


        };
        await dbHelper.insertProductRegistrationData2(productRowData);
      }


      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('')),
      // );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during local backup: $e')),
      );
    } finally {
      setState(() => _isLoadingLocalBackup = false); 
    }
  }



 bool _isLoadingBackup = false;
  bool _isLoadingCompany = false; 

Future<void> fetchDataAndStoreInXML() async {
  try {
    final query = 'SELECT * FROM Account_Transactions'; 

    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);

      if (decodedData is List) {
        List<String> expectedColumns = [
          "Auto", "atDate", "atLedCode", "atType", "atEntryno", "atDebitAmount",
          "atCreditAmount", "atNarration", "atOpposite", "atSalesEntryno",
          "atSalesType", "atLocation", "atChequeNo", "atProject", "atBankEntry",
          "atInvestor", "atFyID", "atFxDebit", "atFxCredit"
        ];

        List<Map<String, dynamic>> validData = [];
        for (var row in decodedData) {
          if (row is Map<String, dynamic>) {
            bool isValid = expectedColumns.every((col) => row.containsKey(col));

            if (isValid) {
              String formattedDate = row["atDate"]?.toString() ?? '';
              try {
                DateTime parsedDate = DateTime.parse(formattedDate);
                formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
              } catch (e) {
                print('Invalid date format for Auto ${row["Auto"]}: $formattedDate');
                formattedDate = ''; 
              }

              row["atDate"] = formattedDate;
              validData.add(Map<String, dynamic>.from(row));
            } else {
              print('Invalid row detected and ignored: $row');
            }
          }
        }

        final builder = xml.XmlBuilder();
        builder.processing('xml', 'version="1.0" encoding="UTF-8"');
        builder.element('Account_Transactions', nest: () {
          for (var row in validData) {
            builder.element('Transaction', nest: () {
              row.forEach((key, value) {
                builder.element(key, nest: value ?? ''); 
              });
            });
          }
        });

        final xmlString = builder.buildDocument().toXmlString(pretty: true);
        print('XML Data: $xmlString');
        final dbHelper = LedgerTransactionsDatabaseHelper.instance;
        await dbHelper.insertXMLData(xmlString);
        print('XML data stored in SQLite successfully!');
        await storeXMLDataInColumns(validData);

      } else {
        throw Exception('Unexpected JSON format in MSSQL data: $decodedData');
      }
    } else {
      throw Exception('Unexpected data format received from MSSQL: $rawData');
    }
  } catch (e) {
    print('Error fetching data from Account_Transactions: $e');
  }
}

Future<void> storeXMLDataInColumns(List<Map<String, dynamic>> data) async {
  try {
    final db = await LedgerTransactionsDatabaseHelper.instance;

    for (var row in data) {
      Map<String, dynamic> rowData = {
        'Auto': row['Auto'] ?? '',
        'atDate': row['atDate'] ?? '',
        'atLedCode': row['atLedCode'] ?? '',
        'atType': row['atType'] ?? '',
        'atEntryno': row['atEntryno'] ?? '',
        'atDebitAmount': row['atDebitAmount'] ?? 0.0,
        'atCreditAmount': row['atCreditAmount'] ?? 0.0,
        'atNarration': row['atNarration'] ?? '',
        'atOpposite': row['atOpposite'] ?? '',
        'atSalesEntryno': row['atSalesEntryno'] ?? '',
        'atSalesType': row['atSalesType'] ?? '',
        'atLocation': row['atLocation'] ?? '',
        'atChequeNo': row['atChequeNo'] ?? '',
        'atProject': row['atProject'] ?? '',
        'atBankEntry': row['atBankEntry'] ?? '',
        'atInvestor': row['atInvestor'] ?? '',
        'atFyID': row['atFyID'] ?? '',
        'atFxDebit': row['atFxDebit'] ?? 0.0,
        'atFxCredit': row['atFxCredit'] ?? 0.0,
      };

      await db.insertData([rowData]);  
    }

    print(' All rows have been successfully inserted into SQLite');
  } catch (e) {
    print(' Error inserting XML data into columns: $e');
  }
}





  Future<void> performBackup() async {
    setState(() => _isLoadingCompany = true); 
    try {
       await backupMSSQLToSQLite();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Backup completed successfully.'))
      // );
      print("");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during backup: $e'))
      );
      print("Error during backup: $e");
    } finally {
      setState(() => _isLoadingCompany = false); 
    }
  }
  
  Future<void> companyBackup() async {
    setState(() => _isLoadingCompany = true); 
    try {
      await backupMSSQLToSQLite2();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company backup completed successfully.'))
      );
      print("Company backup completed successfully.");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during company backup: $e'))
      );
      print("Error during company backup: $e");
    } finally {
      setState(() => _isLoadingCompany = false); 
    }
  }
  


 
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Appcolors().scafoldcolor,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: Appcolors().maincolor,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white, size: 20),
          ),
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight * 0.01),
            child: Text("BackUp", style: appbarFonts(screenWidth * 0.04, Colors.white)),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight * 0.02),
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.more_vert, color: Colors.white, size: screenHeight*0.03),
            ),
          ),
        ],
      ),
      body: Center(
  child: Column(
    children: [
      SizedBox(height: screenHeight * 0.3),

      GestureDetector(
        onTap: _isLoadingBackup 
            ? null  
            : () async {
                setState(() => _isLoadingBackup = true);

                try {
                  await backupToLocalDatabase(); 
                  Fluttertoast.showToast(msg: 'Backup process completed successfully!');
                
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error during backup: $e'))
                  );
                } finally {
                  setState(() => _isLoadingBackup = false); 
                }
            },
        child: Container(
          height: screenHeight * 0.07,
          width: screenWidth * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _isLoadingBackup 
                ? Colors.grey 
                : Appcolors().maincolor,
          ),
          child: Center(
            child: _isLoadingBackup
                ? CircularProgressIndicator(color: Colors.white) 
                : Text("BackUp Data", style: getFonts(14, Colors.white)),
          ),
        ),
      ),

      SizedBox(height: 20),

      GestureDetector(
        onTap:  _isLoadingCompany
            ? null  
            : () async {
                setState(() => _isLoadingCompany = true); 
                try {
                  //await companyBackup();
                   //await fetchDataAndStoreInXML();
                   await performBackup();
                   Fluttertoast.showToast(msg: 'Backup completed successfully!');
                  
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error during company backup: $e'))
                  );
                } finally {
                  setState(() => _isLoadingCompany = false); 
                }
            },
        child: Container(
          height: screenHeight * 0.07,
          width: screenWidth * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _isLoadingCompany
                ? Colors.grey 
                : Appcolors().maincolor,
          ),
          child: Center(
            child: _isLoadingCompany
                ? CircularProgressIndicator(color: Colors.white)
                : Text("Accounts Data", style: getFonts(14, Colors.white)),
          ),
        ),
      ),
    ],
  ),
),

    );
  }
}
