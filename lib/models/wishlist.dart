import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Wishlist extends Equatable {
 final String id;
 final String ownerId;
 final String name;

 

 final int itemCount;
final Timestamp createdAt;

 const Wishlist({
 required this.id,
 required this.ownerId,
 required this.name,

 required this.itemCount,
 required this.createdAt,
 });



 @override
 List<Object?> get props => [
 id,
 ownerId,
 name,
 itemCount,
 createdAt
 ];

 factory Wishlist.fromSnapshot(DocumentSnapshot doc) {
 final data = doc.data() as Map<String, dynamic>;
 
 return Wishlist(
 id: doc.id,
 ownerId: data['ownerId'] ?? '',
 name: data['name'] ?? '',

 createdAt: data['createdAt'] ?? Timestamp.now(),
 itemCount: data['itemCount'] ?? 0,
 );
 }

 Map<String, dynamic> toJson() {
 return {
 'ownerId': ownerId,
 'name': name,
 'createdAt': createdAt,

 'itemCount': itemCount,
 };
 }
}