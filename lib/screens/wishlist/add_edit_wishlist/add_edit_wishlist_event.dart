import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../models/wishlist.dart';

abstract class AddEditWishlistEvent extends Equatable {
 const AddEditWishlistEvent();
 @override List<Object?> get props => [];
}

class CreateWishlist extends AddEditWishlistEvent {
 final String name;
 // ❌ Замість final IconData icon; тепер використовуємо компоненти:
 final int iconCodePoint;
 final String iconFontFamily;
 final String? iconFontPackage; // Може бути null

 const CreateWishlist({
 required this.name,
 required this.iconCodePoint,
 required this.iconFontFamily,
 this.iconFontPackage, // Не обов'язково
 });

 @override 
 List<Object?> get props => [name, iconCodePoint, iconFontFamily, iconFontPackage];
}

class UpdateWishlist extends AddEditWishlistEvent {
 final Wishlist wishlist;
 const UpdateWishlist({required this.wishlist});
 @override List<Object?> get props => [wishlist];
}

