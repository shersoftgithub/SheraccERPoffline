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
  final double openingBalance;  // New field for opening balance
  final double receivedBalance; // New field for received balance
  final double payAmount;       // New field for pay amount

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
    required this.openingBalance, // Initialize opening balance
    required this.receivedBalance, // Initialize received balance
    required this.payAmount,       // Initialize pay amount
  });

  // Convert Ledger object to a Map for inserting into the database
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
      'opening_balance': openingBalance,  // Add opening balance to the map
      'received_balance': receivedBalance, // Add received balance to the map
      'pay_amount': payAmount,            // Add pay amount to the map
    };
  }

  // Convert Map from the database to a Ledger object
  static Ledger fromMap(Map<String, dynamic> map) {
    return Ledger(
      id: map['id'],
      ledgerName: map['ledger_name'] ?? "",
      under: map['under'],
      address: map['address'],
      contact: map['contact'],
      mail: map['mail'],
      taxNo: map['tax_no'],
      priceLevel: map['price_level'],
      balance: map['balance'],
      openingBalance: map['opening_balance'] ?? 0.0,  // Default to 0.0 if not available
      receivedBalance: map['received_balance'] ?? 0.0, // Default to 0.0 if not available
      payAmount: map['pay_amount'] ?? 0.0,            // Default to 0.0 if not available
    );
  }
}
