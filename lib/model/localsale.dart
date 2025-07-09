class LocalMilkSale {
  String? id;
  String? customerId;
  String? adminId;
  String date;
  String paymentType;
  String milkType;
  double quantity;
  double rate;
  double totalValue;

  LocalMilkSale( {
    this.id,
    this.customerId,
    this.adminId,
    required this.date,
    required this.paymentType,
    required this.milkType,
    required this.quantity,
    required this.rate,
    required this.totalValue,
  });

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'customerId': customerId,
      'adminId': adminId,
      'date': date,
      'paymentType': paymentType,
      'milkType': milkType,
      'quantity': quantity,
      'rate': rate,
      'totalValue': totalValue,
    };
  }

  // Create object from JSON
  factory LocalMilkSale.fromJson(Map<String, dynamic> json) {
    return LocalMilkSale(
      id:json['id'],
      customerId: json['customerId'],
      adminId: json['adminId'],
      date: json['date'],
      paymentType: json['paymentType'],
      milkType: json['milkType'],
      quantity: (json['quantity']),
      rate: (json['rate']),
      totalValue: (json['totalValue']),
    );
  }
}
