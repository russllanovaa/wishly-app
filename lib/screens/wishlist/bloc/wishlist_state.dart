import 'package:equatable/equatable.dart';
import '../../../models/wishlist.dart'; 

abstract class WishlistState extends Equatable {
  final List<Wishlist> wishlists;
  const WishlistState({this.wishlists = const []});

  @override
  List<Object> get props => [wishlists];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {
  const WishlistLoading({required super.wishlists});
}

class WishlistData extends WishlistState {
  const WishlistData({required super.wishlists});
}

class WishlistError extends WishlistState {
  final String message;
  const WishlistError({required this.message, required super.wishlists});

  @override
  List<Object> get props => [wishlists, message];
}