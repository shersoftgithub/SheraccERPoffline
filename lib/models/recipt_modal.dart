class RecieptModel {
  final int? id; 
  final String date;
  final String cashAccount;
  final String ledgerName;
  final double balance;
  final double amount;
  final double discount;
  final double total;
  final String narration;

  RecieptModel({
    this.id,
    required this.date,
    required this.cashAccount,
    required this.ledgerName,
    required this.balance,
    required this.amount,
    required this.discount,
    required this.total,
    required this.narration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'cashAccount': cashAccount,
      'ledgerName': ledgerName,
      'balance': balance,
      'amount': amount,
      'discount': discount,
      'total': total,
      'narration': narration,
    };
  }

  factory RecieptModel.fromMap(Map<String, dynamic> map) {
    return RecieptModel(
      id: map['id'],
      date: map['date'],
      cashAccount: map['cashAccount'],
      ledgerName: map['ledgerName'],
      balance: map['balance'],
      amount: map['amount'],
      discount: map['discount'],
      total: map['total'],
      narration: map['narration'],
    );
  }
}
