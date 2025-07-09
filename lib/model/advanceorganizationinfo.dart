import 'package:hive/hive.dart';

part '../hive/advanceorganizationinfo.g.dart';

@HiveType(typeId: 6)
class AdvanceOrganization extends HiveObject {
  @HiveField(0)
  String date;

  @HiveField(1)
  double previousBalance;

  @HiveField(2)
  double addAmount;

  @HiveField(3)
  double totalBalance;

  @HiveField(4)
  String adminId;

  AdvanceOrganization({
    required this.date,
    required this.previousBalance,
    required this.addAmount,
    required this.totalBalance,
    required this.adminId
  });

  // Factory method to create an instance from JSON
  factory AdvanceOrganization.fromJson(Map<String, dynamic> json) {
    return AdvanceOrganization(
      addAmount: json['addAmount'] ?? 0,
      previousBalance: json['previousBalance'] ?? 0,
      totalBalance: json['totalBalance'] ?? 0,
      date: json['date'] ?? '',
      adminId: json['adminId']
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'addAmount': addAmount,
      'previousBalance': previousBalance,
      'totalBalance': totalBalance,
      'date': date,
      'adminId':adminId
    };
  }
}

