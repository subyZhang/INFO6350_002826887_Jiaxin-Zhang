import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final _itemsRef = FirebaseFirestore.instance.collection('items');

  Stream<List<Item>> getItems() {
    return _itemsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Item.fromMap(doc.data(), doc.id)).toList()
    );
  }

  Future<void> addItem(Item item) async {
    await _itemsRef.add(item.toMap());
  }
}
