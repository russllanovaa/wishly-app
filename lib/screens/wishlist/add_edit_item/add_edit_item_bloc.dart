import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../repository/wish_item_repository.dart';
import '../../../../repository/storage_repository.dart';
import '../../../../repository/wishlist_repository.dart';

import 'add_edit_item_event.dart';
import 'add_edit_item_state.dart';

class AddEditItemBloc extends Bloc<AddEditItemEvent, AddEditItemState> {
  final WishItemRepository _itemRepository;
  final StorageRepository _storageRepository;
  final WishlistRepository _wishlistRepository;

  AddEditItemBloc({
    required WishItemRepository itemRepository,
    required StorageRepository storageRepository,
    required WishlistRepository wishlistRepository,
  })  : _itemRepository = itemRepository,
        _storageRepository = storageRepository,
        _wishlistRepository = wishlistRepository,
        super(AddEditItemInitial()) {
    on<CreateItem>(_onCreateItem);
    on<UpdateItem>(_onUpdateItem);
  }

  Future<String?> _uploadImage(File? imageFile, String userId) async {
    if (imageFile == null) return null;
    return await _storageRepository.uploadImage(imageFile, userId);
  }

  Future<void> _onCreateItem(
    CreateItem event,
    Emitter<AddEditItemState> emit,
  ) async {
    emit(AddEditItemLoading());

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(AddEditItemError("Користувач не автентифікований"));
      return;
    }

    try {
      String? finalImageUrl = event.item.imageUrl;

      if (event.imageFile != null) {
        finalImageUrl = await _uploadImage(event.imageFile, userId);
      }

      final finalItem = event.item.copyWith(imageUrl: finalImageUrl);

      await _itemRepository.addItem(event.wishlistId, finalItem);
      await _wishlistRepository.updateItemCount(event.wishlistId, 1);

      emit(AddEditItemSuccess());
    } catch (e) {
      emit(AddEditItemError(e.toString()));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItem event,
    Emitter<AddEditItemState> emit,
  ) async {
    emit(AddEditItemLoading());

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(AddEditItemError("Користувач не автентифікований"));
      return;
    }

    try {
      String? finalImageUrl = event.item.imageUrl;

      if (event.imageFile != null) {
        finalImageUrl = await _uploadImage(event.imageFile, userId);
      }

      final finalItem = event.item.copyWith(imageUrl: finalImageUrl);

      await _itemRepository.updateItem(event.wishlistId, finalItem);
      emit(AddEditItemSuccess());
    } catch (e) {
      emit(AddEditItemError(e.toString()));
    }
  }
}