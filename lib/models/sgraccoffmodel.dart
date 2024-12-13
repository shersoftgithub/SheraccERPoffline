class Sheraccoff {
  int? id;
  String address;
  String contactno;
  String mailid;
  String taxno;
  String pricelevel;
  String balance;

  Sheraccoff({
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
      'id': id,
      'address': address,
      'contactno': contactno,
      'mailid': mailid,
      'taxno': taxno,
      'pricelevel': pricelevel,
      'balance': balance,
    };
  }

  factory Sheraccoff.fromMap(Map<String, dynamic> map) {
    return Sheraccoff(
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
