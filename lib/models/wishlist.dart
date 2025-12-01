import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Wishlist extends Equatable {
  final String id;
  final String ownerId; 
  final String name;
  final IconData icon;
  final int itemCount; 
  final Timestamp createdAt; 

  const Wishlist({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.icon,
    required this.itemCount, 
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, ownerId, name, icon, itemCount, createdAt];

  factory Wishlist.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Wishlist(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      icon: IconData(
        data['iconCodePoint'] ?? Icons.card_giftcard.codePoint,
        fontFamily: data['iconFontFamily'] ?? 'MaterialIcons',
      ),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      itemCount: data['itemCount'] ?? 0, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'name': name,
      'createdAt': createdAt,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'itemCount': itemCount, 
    };
  }
}