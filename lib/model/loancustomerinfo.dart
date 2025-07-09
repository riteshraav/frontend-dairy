// import 'package:hive/hive.dart';
// part 'loancustomerinfo.g.dart';
//
// @HiveType(typeId: 8)
// class LoanEntry extends HiveObject {
//   @HiveField(0)
//   String date;
//
//   @HiveField(1)
//   String customerId;
//
//   @HiveField(2)
//   String adminId;
//
//   @HiveField(3)
//   double loanAmount;
//
//   @HiveField(4)
//   String note;
//
//   @HiveField(5)
//   double interestRate;
//
//   @HiveField(6)
//   String modeOfPayback;
//
//   @HiveField(7)
//   double remainingInterest;
//   @HiveField(8)
//   String recentDeduction;
//
//   LoanEntry({
//     required this.date,
//     required this.customerId,
//     required this.adminId,
//     required this.loanAmount,
//     required this.note,
//     required this.interestRate,
//     required this.modeOfPayback,
//     required this.remainingInterest,
//     required this.recentDeduction
//   });
//
//   // Factory constructor for JSON deserialization
//   factory LoanEntry.fromJson(Map<String, dynamic> json) {
//     return LoanEntry(
//       date: json['date'],
//       customerId: json['customerId'],
//       adminId: json['adminId'],
//       loanAmount: (json['loanAmount'] as num).toDouble(),
//       note: json['note'],
//       interestRate: (json['interestRate'] as num).toDouble(),
//       modeOfPayback: json['modeOfPayback'],
//       remainingInterest: json['remainingInterest'],
//       recentDeduction: json['recentDeduction']
//     );
//   }
//
//   // Method to convert an object back to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'date': date,
//       'customerId': customerId,
//       'adminId': adminId,
//       'loanAmount': loanAmount,
//       'note': note,
//       'interestRate': interestRate,
//       'modeOfPayback': modeOfPayback,
//       'remainingInterest':remainingInterest,
//       'recentDeduction':recentDeduction
//     };
//   }
// }
import 'package:hive/hive.dart';
part 'loancustomerinfo.g.dart';

@HiveType(typeId: 8)
class LoanEntry extends HiveObject {
  @HiveField(0)
  String date;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  String adminId;

  @HiveField(3)
  double? loanAmount;

  @HiveField(4)
  String note;

  @HiveField(5)
  double? interestRate;

  @HiveField(6)
  String modeOfPayback;

  @HiveField(7)
  double? remainingInterest;

  @HiveField(8)
  String recentDeduction;

  LoanEntry({
    required this.date,
    required this.customerId,
    required this.adminId,
    required this.loanAmount,
    required this.note,
    required this.interestRate,
    required this.modeOfPayback,
    required this.remainingInterest,
    required this.recentDeduction,
  });

  factory LoanEntry.fromJson(Map<String, dynamic> json) {
    return LoanEntry(
      date: json['date'],
      customerId: json['customerId'],
      adminId: json['adminId'],
      loanAmount: (json['loanAmount'] as num?)?.toDouble(),
      note: json['note'],
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      modeOfPayback: json['modeOfPayback'],
      remainingInterest: (json['remainingInterest'] as num?)?.toDouble(),
      recentDeduction: json['recentDeduction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'customerId': customerId,
      'adminId': adminId,
      'loanAmount': loanAmount,
      'note': note,
      'interestRate': interestRate,
      'modeOfPayback': modeOfPayback,
      'remainingInterest': remainingInterest,
      'recentDeduction': recentDeduction,
    };
  }
}
