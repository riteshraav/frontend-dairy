class MilkCollection{
  String? id;
  String? adminId;
  String? customerId;
  double? quantity;
  double? fat;
  double? snf;
  double? rate;
  double? totalValue;
  String? time;
  String? milkType;
  String? date;

  MilkCollection({
    this.id,
    this.adminId,
    this.customerId,
    this.quantity,
    this.fat,
    this.snf,
    this.rate,
    this.totalValue,
    this.time,
    this.milkType,
    this.date, });

  factory MilkCollection.formJson(Map<String,dynamic> json){
    return MilkCollection(
       id:json['id'],
        adminId : json['adminId'],
        customerId :json['customerId'],
        quantity:json['quantity'],
        fat:json['fat'],
        snf:json['snf'],
        rate:json['rate'],
        totalValue:json['totalValue'],
        time:json['time'],
        milkType:json['milkType'],
        date:json['date']);
  }
  Map<String,dynamic>toJson(){
    return{
      'id':id,
      'adminId':adminId,
      'customerId':customerId,
      'quantity':quantity,
      'fat':fat,
      'snf':snf,
      'rate':rate,
      'totalValue':totalValue,
      'time':time,
      'date':date,
      'milkType':milkType


    };
  }
}