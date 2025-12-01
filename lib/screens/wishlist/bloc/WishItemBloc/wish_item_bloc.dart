import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repository/wish_item_repository.dart';
import '../../../../repository/wishlist_repository.dart';
import 'wish_item_event.dart';
import 'wish_item_state.dart';

class WishItemBloc extends Bloc<WishItemEvent, WishItemState> {
  final WishItemRepository _itemRepository;
  final WishlistRepository _wishlistRepository;
  
  StreamSubscription? _itemSubscription;
  
  String _wishlistId = '';

  WishItemBloc({
    required WishItemRepository itemRepository,
    required WishlistRepository wishlistRepository,
    })
      : _itemRepository = itemRepository,
      _wishlistRepository = wishlistRepository,
        super(WishItemInitial()) {
    
    on<LoadItems>(_onLoadItems);
    on<UpdateItemsList>(_onUpdateItemsList);
    on<DeleteItem>(_onDeleteItem);
    on<ToggleItemBooked>(_onToggleItemBooked);
  }

  void _onLoadItems(LoadItems event, Emitter<WishItemState> emit) {
    emit(WishItemLoading());

    _wishlistId = event.wishlistId; 
    
    _itemSubscription?.cancel();
    _itemSubscription = _itemRepository.getItems(event.wishlistId).listen(
      (items) {
        add(UpdateItemsList(items: items));
      },
      onError: (error) {
        emit(WishItemError(message: error.toString(), items: state.items));
      },
    );
  }

  void _onUpdateItemsList(UpdateItemsList event, Emitter<WishItemState> emit) {
    emit(WishItemData(items: event.items));
  }

  Future<void> _onDeleteItem(
    DeleteItem event,
    Emitter<WishItemState> emit,
  ) async {
    try {
      await _itemRepository.deleteItem(_wishlistId, event.item.id);
      await _wishlistRepository.updateItemCount(_wishlistId, -1);
    } catch (e) {
      emit(WishItemError(message: "Помилка видалення: ${e.toString()}", items: state.items));
    }
  }

  Future<void> _onToggleItemBooked(
    ToggleItemBooked event,
    Emitter<WishItemState> emit,
  ) async {
    try {
      final updatedItem = event.item.copyWith(isBooked: !event.item.isBooked);
      
      await _itemRepository.updateItem(_wishlistId, updatedItem);
    } catch (e) {
      emit(WishItemError(message: "Помилка бронювання: ${e.toString()}", items: state.items));
    }
  }

  @override
  Future<void> close() {
    _itemSubscription?.cancel();
    return super.close();
  }
}