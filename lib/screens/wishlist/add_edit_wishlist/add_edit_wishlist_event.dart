import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../models/wishlist.dart';

abstract class AddEditWishlistEvent extends Equatable {
  const AddEditWishlistEvent();
  @override List<Object?> get props => [];
}

class CreateWishlist extends AddEditWishlistEvent {
  final String name;
  final IconData icon;
  const CreateWishlist({required this.name, required this.icon});
  @override List<Object?> get props => [name, icon];
}

class UpdateWishlist extends AddEditWishlistEvent {
  final Wishlist wishlist;
  const UpdateWishlist({required this.wishlist});
  @override List<Object?> get props => [wishlist];
}