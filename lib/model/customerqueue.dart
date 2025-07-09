import 'package:hive/hive.dart';

part '../hive/customerqueue.g.dart';

@HiveType(typeId: 2)
class CustomerQueue extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  List<dynamic> customer;//id,code,name,phone,buffalo,cow,adminId

  CustomerQueue({required this.id, required this.customer});

  // Convert Customer to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer': customer,
    };
  }

  // Convert Map to Customer
  factory CustomerQueue.fromMap(Map<String, dynamic> map) {
    return CustomerQueue(
      id: map['id'],
      customer: map['customer'],
    );
  }
}
