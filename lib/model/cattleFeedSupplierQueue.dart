import 'package:hive/hive.dart';

part '../hive/cattleFeedSupplierQueue.g.dart';

@HiveType(typeId: 4)
class CattleFeedSupplierQueue extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  List<dynamic> cattleFeedSupplier;//id,code,name,phone,buffalo,cow,adminId

  CattleFeedSupplierQueue({required this.id, required this.cattleFeedSupplier});

  // Convert Customer to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cattleFeedSupplier': cattleFeedSupplier,
    };
  }

  // Convert Map to Customer
  factory CattleFeedSupplierQueue.fromMap(Map<String, dynamic> map) {
    return CattleFeedSupplierQueue(
      id: map['id'],
      cattleFeedSupplier: map['cattleFeedSupplier'],
    );
  }
}
