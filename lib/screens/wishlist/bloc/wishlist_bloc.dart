import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/wishlist.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';
import '../../../repository/wishlist_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _wishlistRepository;
  
  StreamSubscription? _wishlistSubscription;
  
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<Wishlist> _allWishlists = [];
  String _currentFilter = '';
  String _currentSort = 'name'; 

  WishlistBloc({required WishlistRepository wishlistRepository})
      : _wishlistRepository = wishlistRepository,
        super(WishlistInitial()) {
    on<LoadWishlists>(_onLoadWishlists);
    on<UpdateWishlistsList>(_onUpdateWishlistsList);
    on<FetchWishlistsWithError>(_onFetchWishlistsWithError);
    on<FilterWishlists>(_onFilterWishlists);
    on<SortWishlists>(_onSortWishlists);
    on<DeleteWishlist>(_onDeleteWishlist);
  }

  void _onLoadWishlists(
    LoadWishlists event,
    Emitter<WishlistState> emit,
  ) {
    if (_userId.isEmpty) {
      emit(WishlistError(message: "Користувач не автентифікований", wishlists: []));
      return;
    }

    emit(WishlistLoading(wishlists: state.wishlists));
    _wishlistSubscription?.cancel();
    _wishlistSubscription = _wishlistRepository
        .getWishlists(_userId)
        .listen(
          (wishlists) {
            add(UpdateWishlistsList(wishlists: wishlists));
          },
          onError: (error) {
            emit(WishlistError(
              message: 'Помилка завантаження: ${error.toString()}',
              wishlists: state.wishlists,
            ));
          },
        );
  }

  void _onUpdateWishlistsList(
    UpdateWishlistsList event,
    Emitter<WishlistState> emit,
  ) {
    _allWishlists = event.wishlists;
    final filteredSorted = _applyFilterAndSort(_allWishlists);
    emit(WishlistData(wishlists: filteredSorted));
  }

  Future<void> _onFetchWishlistsWithError(
    FetchWishlistsWithError event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading(wishlists: state.wishlists));
    try {
      await Future.delayed(const Duration(seconds: 1));
      throw Exception('Помилка завантаження! Спробуйте знову.');
    } catch (e) {
      emit(WishlistError(
        message: e.toString(),
        wishlists: state.wishlists,
      ));
    }
  }

  void _onFilterWishlists(
    FilterWishlists event,
    Emitter<WishlistState> emit,
  ) {
    _currentFilter = event.query.toLowerCase();
    final filteredSorted = _applyFilterAndSort(_allWishlists);
    emit(WishlistData(wishlists: filteredSorted));
  }

  void _onSortWishlists(
    SortWishlists event,
    Emitter<WishlistState> emit,
  ) {
    _currentSort = event.by;
    final filteredSorted = _applyFilterAndSort(_allWishlists);
    emit(WishlistData(wishlists: filteredSorted));
  }

  Future<void> _onDeleteWishlist(
    DeleteWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      await _wishlistRepository.deleteWishlist(event.id);
    } catch (e) {
      emit(WishlistError(
        message: 'Помилка видалення: ${e.toString()}',
        wishlists: state.wishlists, 
      ));
    }
  }

  List<Wishlist> _applyFilterAndSort(List<Wishlist> wishlists) {
    List<Wishlist> filtered = wishlists;
    if (_currentFilter.isNotEmpty) {
      filtered = wishlists
          .where((wishlist) =>
              wishlist.name.toLowerCase().contains(_currentFilter))
          .toList();
    }

    List<Wishlist> sorted = List.from(filtered);
    sorted.sort((a, b) {
      switch (_currentSort) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'date':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return sorted;
  }

  @override
  Future<void> close() {
    _wishlistSubscription?.cancel();
    return super.close();
  }
}