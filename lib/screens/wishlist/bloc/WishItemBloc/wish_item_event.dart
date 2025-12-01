import 'package:equatable/equatable.dart';
import '../../../../models/wish_item.dart';

abstract class WishItemEvent extends Equatable {
  const WishItemEvent();
  @override
  List<Object> get props => [];
}

class LoadItems extends WishItemEvent {
  final String wishlistId;
  const LoadItems({required this.wishlistId});

  @override
  List<Object> get props => [wishlistId];
}

class UpdateItemsList extends WishItemEvent {
  final List<WishItem> items;
  const UpdateItemsList({required this.items});

  @override
  List<Object> get props => [items];
}

class DeleteItem extends WishItemEvent {
  final WishItem item;

  const DeleteItem({required this.item});

  @override
  List<Object> get props => [item];
}

class ToggleItemBooked extends WishItemEvent {
  final WishItem item;

  const ToggleItemBooked({required this.item});

  @override
  List<Object> get props => [item];
}