import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../../models/wish_item.dart';

abstract class AddEditItemEvent extends Equatable {
  const AddEditItemEvent();
  @override List<Object?> get props => [];
}

class CreateItem extends AddEditItemEvent {
  final String wishlistId;
  final WishItem item;
  final File? imageFile;

  const CreateItem({
    required this.wishlistId,
    required this.item,
    this.imageFile, 
  });

  @override
  List<Object?> get props => [wishlistId, item, imageFile];
}

class UpdateItem extends AddEditItemEvent {
  final String wishlistId;
  final WishItem item;
  final File? imageFile;

  const UpdateItem({
    required this.wishlistId,
    required this.item,
    this.imageFile, 
  });

  @override
  List<Object?> get props => [wishlistId, item, imageFile];
}