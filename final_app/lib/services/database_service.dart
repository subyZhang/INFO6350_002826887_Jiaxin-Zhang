import 'package:firebase_database/firebase_database.dart';
import '../models/item.dart';

class DatabaseService {
  final DatabaseReference _itemsRef = FirebaseDatabase.instance.ref().child('items');

  Future<void> addItem(Item item) async {
    final newItemRef = _itemsRef.push();
    await newItemRef.set(item.toMap());
  }

  Stream<List<Item>> getItems() {
    return _itemsRef.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.entries.map((e) {
        return Item.fromMap(Map<String, dynamic>.from(e.value), e.key);
      }).toList();
    });
  }
}
