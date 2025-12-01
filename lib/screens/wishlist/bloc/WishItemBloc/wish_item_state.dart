import 'package:equatable/equatable.dart';
import '../../../../models/wish_item.dart';

abstract class WishItemState extends Equatable {
  final List<WishItem> items;
  const WishItemState({this.items = const []});

  @override
  List<Object> get props => [items];
}

class WishItemInitial extends WishItemState {}
class WishItemLoading extends WishItemState {}
class WishItemData extends WishItemState {
  const WishItemData({required super.items});
}
class WishItemError extends WishItemState {
  final String message;
  const WishItemError({required this.message, required super.items});

  @override
  List<Object> get props => [items, message];
}