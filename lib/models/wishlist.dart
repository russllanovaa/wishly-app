import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Wishlist extends Equatable {
  final String id;
  final String ownerId;
  final String name;

  final int iconCodePoint;
  final String iconFontFamily;
  final String? iconFontPackage;

  final int itemCount;
  final Timestamp createdAt;

  // Визначаємо IconData за замовчуванням як статичне фінальне поле
  // і зберігаємо її властивості в статичних змінних.
  static final IconData _defaultIcon = Icons.card_giftcard;
  static final int _kDefaultCodePoint = _defaultIcon.codePoint;
  static final String _kDefaultFontFamily = _defaultIcon.fontFamily!;
  // iconFontPackage для MaterialIcons за замовчуванням null.

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
    
    // 💡 Рядок 38, де раніше була помилка, тепер посилається на статичні фінальні поля
    return Wishlist(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      
      // ✅ ВИПРАВЛЕННЯ: Використовуємо статичні фінальні значення для іконок за замовчуванням
      iconCodePoint: data['iconCodePoint'] ?? _kDefaultCodePoint,
      iconFontFamily: data['iconFontFamily'] ?? _kDefaultFontFamily,
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