import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Wishlist extends Equatable {
  final String id;
  final String ownerId;
  final String name;

  // ❌ ВИДАЛЕНО: final IconData icon;
  
  // ✅ ДОДАНО: Поля для зберігання компонентів IconData
  final int iconCodePoint;
  final String iconFontFamily;
  final String? iconFontPackage; // null для MaterialIcons

  final int itemCount;
  final Timestamp createdAt;

  const Wishlist({
    required this.id,
    required this.ownerId,
    required this.name,
    // ✅ Оновлений конструктор для прийому компонентів
    required this.iconCodePoint,
    required this.iconFontFamily,
    this.iconFontPackage, 
    required this.itemCount,
    required this.createdAt,
  });

  // ✅ Геттер для зручного отримання IconData
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
        iconCodePoint, // ✅ Використовуємо прості типи
        iconFontFamily,
        iconFontPackage,
        itemCount, 
        createdAt
      ];

  factory Wishlist.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final defaultIcon = Icons.card_giftcard;
    
    // 💡 ТЕПЕР МИ ЗБЕРІГАЄМО ТІЛЬКИ ЧИСЛА ТА РЯДКИ
    return Wishlist(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      
      // ✅ Більше не створюємо IconData, Flutter задоволений!
      iconCodePoint: data['iconCodePoint'] ?? defaultIcon.codePoint,
      iconFontFamily: data['iconFontFamily'] ?? defaultIcon.fontFamily!,
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
      // ✅ Зберігаємо окремі поля
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'iconFontPackage': iconFontPackage,
      'itemCount': itemCount, 
    };
  }
}