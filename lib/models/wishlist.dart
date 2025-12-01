import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ ВИПРАВЛЕННЯ: Використовуємо 'static final' замість 'const' 
// для коректного доступу до властивостей Icons.
// Ми можемо використовувати 'static final' у фабричному конструкторі, 
// не порушуючи правил tree-shaking, оскільки ми більше не створюємо IconData тут.
abstract class _DefaultIcon {
  static final int codePoint = Icons.card_giftcard.codePoint;
  static final String fontFamily = Icons.card_giftcard.fontFamily!;
}

class Wishlist extends Equatable {
  final String id;
  final String ownerId;
  final String name;

  final int iconCodePoint;
  final String iconFontFamily;
  final String? iconFontPackage;

  final int itemCount;
  final Timestamp createdAt;

  const Wishlist({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.iconFontPackage, 
    required this.itemCount,
    required this.createdAt,
  });

  // Геттер для зручного отримання IconData
  IconData get icon => IconData(
        iconCodePoint,
        fontFamily: iconFontFamily,
        fontPackage: iconFontPackage,
      );

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        iconCodePoint,
        iconFontFamily,
        iconFontPackage,
        itemCount,
        createdAt
      ];

  factory Wishlist.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Wishlist(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      
      // ✅ ВИПРАВЛЕННЯ: Використовуємо static final значення
      iconCodePoint: data['iconCodePoint'] ?? _DefaultIcon.codePoint,
      iconFontFamily: data['iconFontFamily'] ?? _DefaultIcon.fontFamily,
      iconFontPackage: data['iconFontPackage'] as String?,

      createdAt: data['createdAt'] ?? Timestamp.now(),
      itemCount: data['itemCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'name': name,
      'createdAt': createdAt,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'iconFontPackage': iconFontPackage,
      'itemCount': itemCount,
    };
  }
}