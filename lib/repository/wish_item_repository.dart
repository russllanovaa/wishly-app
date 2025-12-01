import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wish_item.dart'; 

abstract class WishItemRepositoryBase {
  Stream<List<WishItem>> getItems(String wishlistId);
  Future<void> addItem(String wishlistId, WishItem item);
  Future<void> updateItem(String wishlistId, WishItem item);
  Future<void> deleteItem(String wishlistId, String itemId);
}

class WishItemRepository implements WishItemRepositoryBase {
  final FirebaseFirestore _firestore;

  WishItemRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<WishItem>> getItems(String wishlistId) {
    return _firestore
        .collection('wishlists')
        .doc(wishlistId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => WishItem.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> addItem(String wishlistId, WishItem item) {
    return _firestore
        .collection('wishlists')
        .doc(wishlistId)
        .collection('items')
        .add(item.toJson());
  }

  @override
  Future<void> updateItem(String wishlistId, WishItem item) {
    return _firestore
        .collection('wishlists')
        .doc(wishlistId)
        .collection('items')
        .doc(item.id)
        .update(item.toJson());
  }

  @override
  Future<void> deleteItem(String wishlistId, String itemId) {
    return _firestore
        .collection('wishlists')
        .doc(wishlistId)
        .collection('items')
        .doc(itemId)
        .delete();
  }
}