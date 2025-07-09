
class CattleFeedSell{
  String? id;
  String? customerId;
  String? feedName;
  int? quantity;
  double? rate;
  double? totalAmount;
  String? date;
  String? adminId;
  String? modeOfPayback;
  double? totalCattleFeedBalance;
  double? deduction;

  CattleFeedSell(
      {
        this.id,
        this.customerId,
      this.feedName,
      this.quantity,
      this.rate,
      this.totalAmount,
      this.date,
      this.adminId,
      this.modeOfPayback,
      this.totalCattleFeedBalance,
        this.deduction
      });

  factory CattleFeedSell.fromJson(Map<String,dynamic> json){
    return CattleFeedSell(
      id:json['id'],
      customerId: json['customerId'],
      feedName: json['feedName'],
      quantity: json['quantity'],
      rate: json['rate'],
      totalAmount: json['totalAmount'],
      date: json['date'],
      adminId: json['adminId'],
      modeOfPayback: json['modeOfPayback'],
      totalCattleFeedBalance: json['totalCattleFeedBalance'],
        deduction:json['deduction']
    );
  }
  Map<String , dynamic> toJson(){
    return {
      'id':id,
      'customerId':customerId,
      'feedName':feedName,
      'quantity':quantity,
      'rate':rate,
      'totalAmount':totalAmount,
      'date':date,
      'adminId':adminId,
      'modeOfPayback':modeOfPayback,
      'totalCattleFeedBalance':totalCattleFeedBalance,
      'deduction':deduction
    };
  }
}