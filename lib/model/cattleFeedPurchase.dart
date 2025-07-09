class CattleFeedPurchase{
  String? voucher;
  String? code;
  String? feedName;
  String? supplier;
  int? quantity;
  double? rate;
  double? amount;
  double? gst;
  double? gstAmount;
  double? commission;
  double? wages;
  double? billAmount;
  String? paymentMethod;
  String? date;
  double? totalAmount;
  String? adminId;

  CattleFeedPurchase(
      {this.voucher,
      this.code,
        this.feedName,
      this.supplier,
      this.quantity,
      this.rate,
      this.amount,
      this.gst,
      this.gstAmount,
      this.commission,
      this.wages,
      this.billAmount,
      this.paymentMethod,
      this.date,
      this.totalAmount,
      this.adminId,
      });

  factory CattleFeedPurchase.fromJson(Map<String,dynamic> json){
    return CattleFeedPurchase(
        voucher:json['voucher'],
        feedName: json['feedName'],
        code:json['code'],
        supplier:json['supplier'],
        quantity:json['quantity'],
        rate : json['rate'],
        amount : json['amount'],
        gst : json['gst'],
        gstAmount : json['gstAmount'],
        commission:json['commission'],
        wages:json['wages'],
        billAmount:json['billAmount'],
        paymentMethod : json['paymentMethod'],
        date:json['date'],
        totalAmount:json['totalAmount'],
        adminId: json['adminId']);
  }
  Map<String,dynamic> toJson(){
    return{
      'voucher':voucher,
      'feedName':feedName,
      'code':code,
      'supplier' : supplier,
      'quantity':quantity,
      'rate':rate,
      'amount':amount,
      'gst':gst,
      'gstAmount':gstAmount,
      'commission':commission,
      'wages':wages,
      'billAmount':billAmount,
      'paymentMethod':paymentMethod,
      'date':date,
      'totalAmount':totalAmount,
      'adminId':adminId
    };
  }
}