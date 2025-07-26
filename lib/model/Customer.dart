import 'package:hive/hive.dart';
part '../hive/customer.g.dart';

@HiveType(typeId: 1)
class Customer {

  @HiveField(0)
  String? code;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? phone;

  @HiveField(3)
  bool? buffalo;

  @HiveField(4)
  bool? cow;

  @HiveField(5)
  String? adminId;

  @HiveField(6)
  String? classType;

  @HiveField(7)
  String? branchName;

  @HiveField(8)
  String? gender;

  @HiveField(9)
  String? caste;

  @HiveField(10)
  String? alternateNumber;

  @HiveField(11)
  String? email;

  @HiveField(12)
  String? accountNo;

  @HiveField(13)
  String? bankCode;

  @HiveField(14)
  String? sabhasadNo;

  @HiveField(15)
  String? bankBranchName;

  @HiveField(16)
  String? bankAccountNo;

  @HiveField(17)
  String? ifscNo;

  @HiveField(18)
  String? aadharNo;

  @HiveField(19)
  String? panNo;

  @HiveField(20)
  int? animalCount;

  @HiveField(21)
  double? averageMilk;

  @HiveField(22)
  bool? loan ;

  @HiveField(23)
  bool? advance ;


  // Use a named parameter constructor with proper assignments
  Customer({
    this.code,
    this.name,
    this.phone,
    this.buffalo,
    this.cow,
    this.adminId,
    this.classType,
    this.branchName,
    this.gender,
    this.caste,
    this.alternateNumber,
    this.email,
    this.accountNo,
    this.bankCode,
    this.sabhasadNo,
    this.bankBranchName,
    this.bankAccountNo,
    this.ifscNo,
    this.aadharNo,
    this.panNo,
    this.animalCount,
    this.averageMilk,
  });

  // Factory constructor for JSON deserialization
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      code:json['code'],
      name: json['name'],
      phone: json['phone'],
      buffalo: json['buffalo'],
      cow :json['cow'],
      adminId: json['adminId'],
      classType: json['classType'],
      branchName: json['branchName'],
      gender: json['gender'],
      caste: json['caste'],
      alternateNumber: json['alternateNumber'],
      email: json['email'],
      accountNo: json['accountNo'],
      bankCode: json['bankCode'],
      sabhasadNo: json['sabhasadNo'],
      bankBranchName: json['bankBranchName'],
      ifscNo: json['ifscNo'],
      aadharNo: json['aadharNo'],
      panNo: json['panNo'],
      animalCount: json['animalCount'],
        averageMilk:json['averageMilk'],

    );
  }


  // Method to convert an object back to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'phone': phone,
      'buffalo': buffalo,
      'cow': cow,
      'adminId': adminId,
      'classType': classType,
      'branchName': branchName,
      'gender': gender,
      'caste': caste,
      'alternateNumber': alternateNumber,
      'email': email,
      'accountNo': accountNo,
      'bankCode': bankCode,
      'sabhasadNo': sabhasadNo,
      'bankBranchName': bankBranchName,
      'ifscNo': ifscNo,
      'aadharNo': aadharNo,
      'panNo': panNo,
      'animalCount': animalCount,
      'averageMilk': averageMilk,

    };
  }

}
