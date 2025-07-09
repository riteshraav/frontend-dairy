import 'package:hive/hive.dart';
part '../hive/advancecustomerinfo.g.dart';

@HiveType(typeId: 5)
class AdvanceEntry extends HiveObject {
  @HiveField(0)
  String date;

  @HiveField(1)
  String code;

  @HiveField(2)
  String name;

  @HiveField(3)
  double advanceAmount;

  @HiveField(4)
  String note;

  @HiveField(5)
  double interestRate;

  @HiveField(6)
  String paymentMethod;


  @HiveField(7)
  String adminId;

  @HiveField(8)
  double remainingInterest;
  @HiveField(9)
  String recentDeduction;

  @HiveField(10)
  String? id;

  AdvanceEntry({
    required this.date,
    required this.code,
    required this.name,
    required this.advanceAmount,
    required this.note,
    required this.interestRate,
    required this.paymentMethod,
    required this.adminId,
    required this.remainingInterest,
    required this.recentDeduction,
    this.id
  });

  // Factory constructor for JSON deserialization
  factory AdvanceEntry.fromJson(Map<String, dynamic> json) {
    return AdvanceEntry(
      id:json['id'],
      date: json['date'],
      code: json['code'],
      name: json['name'],
      advanceAmount: json['advanceAmount'] ,
      note: json['note']??"",
      interestRate: json['interestRate'],
      paymentMethod: json['paymentMethod'],
      adminId: json['adminId'],
      remainingInterest: json['remainingInterest'],
      recentDeduction: json['recentDeduction'] ?? ""
    );
  }

  // Method to convert an object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'date': date,
      'code': code,
      'name': name,
      'advanceAmount': advanceAmount,
      'note': note,
      'interestRate': interestRate,
      'paymentMethod': paymentMethod,
      'adminId':adminId,
      'remainingInterest':remainingInterest,
      'recentDeduction':recentDeduction
    };
  }
}
