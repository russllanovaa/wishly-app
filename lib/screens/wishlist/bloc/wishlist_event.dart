import 'package:equatable/equatable.dart';
import '../../../models/wishlist.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();
  @override
  List<Object> get props => [];
}

class FetchWishlists extends WishlistEvent {}

class LoadWishlists extends WishlistEvent {}

class FetchWishlistsWithError extends WishlistEvent {}

class UpdateWishlistsList extends WishlistEvent {
  final List<Wishlist> wishlists;
  const UpdateWishlistsList({required this.wishlists});

  @override
  List<Object> get props => [wishlists];
}

class FilterWishlists extends WishlistEvent {
  final String query;
  const FilterWishlists({required this.query});
  
  @override
  List<Object> get props => [query];
}

class SortWishlists extends WishlistEvent {
  final String by;
  const SortWishlists({required this.by});
  
  @override
  List<Object> get props => [by];
}

class DeleteWishlist extends WishlistEvent {
  final String id;
  const DeleteWishlist({required this.id});
  
  @override
  List<Object> get props => [id];
}