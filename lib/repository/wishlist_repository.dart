import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist.dart'; 

abstract class WishlistRepositoryBase {
  Stream<List<Wishlist>> getWishlists(String userId);
  Future<void> addWishlist(Wishlist wishlist);
  Future<void> updateWishlist(Wishlist wishlist);
  Future<void> deleteWishlist(String wishlistId);
  Future<void> updateItemCount(String wishlistId, int change);
}

class WishlistRepository implements WishlistRepositoryBase {
  final FirebaseFirestore _firestore;

  WishlistRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Wishlist>> getWishlists(String userId) {
    return _firestore
        .collection('wishlists')
        .where('ownerId', isEqualTo: userId) 
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Wishlist.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> addWishlist(Wishlist wishlist) {
    return _firestore.collection('wishlists').add(wishlist.toJson());
  }

  @override
  Future<void> updateWishlist(Wishlist wishlist) {
    return _firestore
        .collection('wishlists')
        .doc(wishlist.id)
        .update(wishlist.toJson());
  }

  @override
  Future<void> deleteWishlist(String wishlistId) {
    return _firestore.collection('wishlists').doc(wishlistId).delete();
  }

  @override
  Future<void> updateItemCount(String wishlistId, int change) {
    return _firestore
        .collection('wishlists')
        .doc(wishlistId)
        .update({'itemCount': FieldValue.increment(change)});
  }
}