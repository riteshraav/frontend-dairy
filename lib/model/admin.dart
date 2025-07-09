import 'package:hive/hive.dart';
part '../hive/admin.g.dart';

@HiveType(typeId: 0)
class Admin {
  @HiveField(0)
  int? code;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? password;

  @HiveField(3)
  String? id;

  @HiveField(4)
  String? dairyName;

  @HiveField(5)
  String? city;

  @HiveField(6)
  String? subDistrict;

  @HiveField(7)
  String? district;

  @HiveField(8)
  String? state;

  @HiveField(9)
  int? customerSequence;

  @HiveField(10)
  int? supplierSequence;

  @HiveField(11)
  double? currentBalance;
  // Default constructor
  Admin({this.code,
    this.name,
    this.password,
    this.id,
    this.dairyName,
    this.city,
    this.subDistrict,
    this.district,
    this.state,
    this.customerSequence,
    this.supplierSequence,
  this.currentBalance});

  // Factory method to create an Admin instance from a JSON object
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      code : json['code'],
      name: json['name'],
      password: json['password'],
      id: json['id'],
      dairyName:json['dairyName'],
      city:json['city'],
      subDistrict :json['subDistrict'],
      district: json['district'],
      state: json['json'],
        customerSequence : json['customerSequence'],
        supplierSequence:json['supplierSequence'],
      currentBalance: json['currentBalance']
    );
  }

  // Method to convert an Admin instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'code':code,
      'customerSequence':customerSequence,
      'name': name,
      'password': password,
      'id': id,
      'dairyName':dairyName,
      'city':city,
      'subDistrict':subDistrict,
      'district':district,
      'state':state,
      'supplierSequence':supplierSequence,
      'currentBalance':currentBalance
    };
  }
}
