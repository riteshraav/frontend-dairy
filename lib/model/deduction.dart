import 'package:flutter/cupertino.dart';

class Deduction {
  String adminId;
  String customerId;
  double? cattleFeed =0;
  double? advance = 0;
  double? creditMilk= 0;
  double? loan= 0;
  double? otherExpense= 0;
  double? doctorVisitFees= 0;
  double? expense= 0;
  String? date;
  double? total= 0;
  double? totalCattleFeedBalance;

  Deduction({
    required this.adminId,
    required this.customerId,
    this.cattleFeed,
    this.advance,
    this.creditMilk,
    this.loan,
    this.otherExpense,
    this.doctorVisitFees,
    this.expense,
    this.date,
    this.total,
    this.totalCattleFeedBalance,
  });

  // Convert JSON to Deduction object
  factory Deduction.fromJson(Map<String, dynamic> json) {
    return Deduction(
        adminId: json['adminId'] ?? '',
        customerId: json['customerId'] ?? '',
        advance: (json['advance'] ?? 0.0).toDouble(),
        doctorVisitFees: (json['doctorVisitFees'] ?? 0.0).toDouble(),
        cattleFeed: (json['cattleFeed'] ?? 0.0).toDouble(),
        creditMilk: (json['creditMilk'] ?? 0.0).toDouble(),
        loan: (json['loan'] ?? 0.0).toDouble(),
        otherExpense: (json['otherExpense'] ?? 0.0).toDouble(),
        expense: (json['expense'] ?? 0.0).toDouble(),
        date: json['date'],
        total: (json['total'] ?? 0.0).toDouble(),
        totalCattleFeedBalance: json['totalCattleFeedBalance']
    );
  }

  // Convert Deduction object to JSON
  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'customerId': customerId,
      'advance': advance,
      'doctorVisitFees': doctorVisitFees,
      'cattleFeed': cattleFeed,
      'creditMilk': creditMilk,
      'loan': loan,
      'otherExpense': otherExpense,
      'expense': expense,
      'date':date,
      'total': total,
      'totalCattleFeedBalance':totalCattleFeedBalance
    };
  }
}
