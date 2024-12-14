class Ledger {
  final int? id;
  final String ledgerName;
  final String under;
  final String address;
  final String contact;
  final String mail;
  final String taxNo;
  final String priceLevel;
  final double balance;

  Ledger({
    this.id,
    required this.ledgerName,
    required this.under,
    required this.address,
    required this.contact,
    required this.mail,
    required this.taxNo,
    required this.priceLevel,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'ledger_name': ledgerName,
      'under': under,
      'address': address,
      'contact': contact,
      'mail': mail,
      'tax_no': taxNo,
      'price_level': priceLevel,
      'balance': balance,
    };
  }

  static Ledger fromMap(Map<String, dynamic> map) {
    return Ledger(
      id: map['id'],
      ledgerName: map['ledger_name']?? "",
      under: map['under'],
      address: map['address'],
      contact: map['contact'],
      mail: map['mail'],
      taxNo: map['tax_no'],
      priceLevel: map['price_level'],
      balance: map['balance'],
    );
  }
}
