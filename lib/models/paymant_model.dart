class PaymentFormModel {
  int? id;
  String address;
  String contactno;
  String mailid;
  String taxno;
  String pricelevel;
  String balance;

  PaymentFormModel({
    this.id,
    required this.address,
    required this.contactno,
    required this.mailid,
    required this.taxno,
    required this.pricelevel,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'contactno': contactno,
      'mailid': mailid,
      'taxno': taxno,
      'pricelevel': pricelevel,
      'balance': balance,
    };
  }

  factory PaymentFormModel.fromMap(Map<String, dynamic> map) {
    return PaymentFormModel(
      id: map['id'],
      address: map['address'],
      contactno: map['contactno'],
      mailid: map['mailid'],
      taxno: map['taxno'],
      pricelevel: map['pricelevel'],
      balance: map['balance'],
    );
  }
}



class SupplierModel {
  final int? id;
  final String suppliername;

  SupplierModel({this.id, required this.suppliername});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'suppliername': suppliername,
    };
  }
  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'],
      suppliername: map['suppliername'],
    );
  }
}
