class CustomerBalance {
  String adminId;
  String customerId;
  double? balanceCattleFeed;
  double? balanceAdvance;
  double? balanceCreditMilk;
  double? balanceLoan;
  double? balanceOtherExpense;
  double? balanceDoctorVisitingFees;
  double? balanceExpense;
  double? totalBalance;

  // Constructor
  CustomerBalance({
    required this.adminId,
    required this.customerId,
    this.balanceCattleFeed,
    this.balanceAdvance,
    this.balanceCreditMilk,
    this.balanceLoan,
    this.balanceOtherExpense,
    this.balanceDoctorVisitingFees,
    this.balanceExpense,
    this.totalBalance,
  });

  // Convert JSON to Dart Object
  factory CustomerBalance.formJson(Map<String, dynamic> json) {
    return CustomerBalance(
      adminId: json['adminId'] ?? '',
      customerId: json['customerId'] ?? '',
      balanceCattleFeed: (json['balanceCattleFeed'] as num?)?.toDouble(),
      balanceAdvance: (json['balanceAdvance'] as num?)?.toDouble(),
      balanceCreditMilk: (json['balanceCreditMilk'] as num?)?.toDouble(),
      balanceLoan: (json['balanceLoan'] as num?)?.toDouble(),
      balanceOtherExpense: (json['balanceOtherExpense'] as num?)?.toDouble(),
      balanceDoctorVisitingFees: (json['balanceDoctorVisitingFees'] as num?)?.toDouble(),
      balanceExpense: (json['balanceExpense'] as num?)?.toDouble(),
      totalBalance: (json['totalBalance'] as num?)?.toDouble(),
    );
  }

  // Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'customerId': customerId,
      'balanceCattleFeed': balanceCattleFeed,
      'balanceAdvance': balanceAdvance,
      'balanceCreditMilk': balanceCreditMilk,
      'balanceLoan': balanceLoan,
      'balanceOtherExpense': balanceOtherExpense,
      'balanceDoctorVisitingFees': balanceDoctorVisitingFees,
      'balanceExpense': balanceExpense,
      'totalBalance': totalBalance,
    };
  }
}
