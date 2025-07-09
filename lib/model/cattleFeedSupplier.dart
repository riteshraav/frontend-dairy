import 'package:hive/hive.dart';
part '../hive/cattleFeedSupplier.g.dart';

@HiveType(typeId: 3)
class CattleFeedSupplier {
  @HiveField(0)
  String? code;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? gender;

  @HiveField(3)
  String? phoneNo;

  @HiveField(4)
  String? alternatePhoneNo;

  @HiveField(5)
  String? email;

  @HiveField(6)
  String? accountNo;

  @HiveField(7)
  String? bankCode;

  @HiveField(8)
  String? sabhasadNo;

  @HiveField(9)
  String? bankBranchName;

  @HiveField(10)
  String? bankAccountNo;

  @HiveField(11)
  String? ifscCode;

  @HiveField(12)
  String? adharNo;

  @HiveField(13)
  String? panNo;

  @HiveField(14)
  String? adminId;

  CattleFeedSupplier({
    this.code,
    this.name,
    this.gender,
    this.phoneNo,
    this.alternatePhoneNo,
    this.email,
    this.accountNo,
    this.bankCode,
    this.sabhasadNo,
    this.bankBranchName,
    this.bankAccountNo,
    this.ifscCode,
    this.adharNo,
    this.panNo,
    this.adminId
  });

  // Convert JSON to Customer object
  factory CattleFeedSupplier.fromJson(Map<String, dynamic> json) {
    return CattleFeedSupplier(
      code: json['code'],
      name: json['name'],
      gender: json['gender'],
      phoneNo: json['phoneNo'],
      alternatePhoneNo: json['alternatePhoneNo'],
      email: json['email'],
      accountNo: json['accountNo'],
      bankCode: json['bankCode'],
      sabhasadNo: json['sabhasadNo'],
      bankBranchName: json['bankBranchName'],
      bankAccountNo: json['bankAccountNo'],
      ifscCode: json['ifscCode'],
      adharNo: json['adharNo'],
      panNo: json['panNo'],
      adminId: json['adminId']
    );
  }

  // Convert Customer object to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'gender': gender,
      'phoneNo': phoneNo,
      'alternatePhoneNo': alternatePhoneNo,
      'email': email,
      'accountNo': accountNo,
      'bankCode': bankCode,
      'sabhasadNo': sabhasadNo,
      'bankBranchName': bankBranchName,
      'bankAccountNo': bankAccountNo,
      'ifscCode': ifscCode,
      'adharNo': adharNo,
      'panNo': panNo,
      'adminId':adminId
    };
  }
}
