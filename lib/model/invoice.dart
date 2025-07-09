import 'Customer.dart';
import 'milk_collection.dart';

class Invoice {
  final MilkCollection milkCollection;
  final Customer customer;
  final List<MilkCollection> milkCollections;

  const Invoice({
    required this.milkCollection,
    required this.customer,
    required this.milkCollections,
  });
}

