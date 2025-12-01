import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/wishlist_repository.dart';
import 'add_edit_wishlist_event.dart';
import 'add_edit_wishlist_state.dart';
import '../../../models/wishlist.dart';

class AddEditWishlistBloc extends Bloc<AddEditWishlistEvent, AddEditWishlistState> {
 final WishlistRepository _wishlistRepository;
 
 AddEditWishlistBloc({required WishlistRepository wishlistRepository})
 : _wishlistRepository = wishlistRepository,
 super(AddEditWishlistInitial()) {
 on<CreateWishlist>(_onCreateWishlist);
 on<UpdateWishlist>(_onUpdateWishlist);
 }

 Future<void> _onCreateWishlist(
    // ⚠️ ПРИМІТКА: Щоб цей код працював, вам необхідно оновити 
    // подію CreateWishlist у файлі 'add_edit_wishlist_event.dart'
    // до таких параметрів: 
    // const CreateWishlist({
    //   required this.name, 
    //   required this.iconCodePoint, 
    //   required this.iconFontFamily, 
    //   this.iconFontPackage
    // });
 CreateWishlist event,
 Emitter<AddEditWishlistState> emit,
 ) async {
 emit(AddEditWishlistLoading());
 
 final userId = FirebaseAuth.instance.currentUser?.uid;
 if (userId == null) {
 emit(AddEditWishlistError("Користувач не автентифікований"));
 return;
 }

 try {
 final newWishlist = Wishlist(
 id: '', 
 ownerId: userId,
 name: event.name,
       
 createdAt: Timestamp.now(),
 itemCount: 0, 
 );
 await _wishlistRepository.addWishlist(newWishlist);
 emit(AddEditWishlistSuccess());
 } catch (e) {
 emit(AddEditWishlistError(e.toString()));
 }
 }

 Future<void> _onUpdateWishlist(
 UpdateWishlist event,
 Emitter<AddEditWishlistState> emit,
 ) async {
 emit(AddEditWishlistLoading());
 try {
 await _wishlistRepository.updateWishlist(event.wishlist);
 emit(AddEditWishlistSuccess());
 } catch (e) {
 emit(AddEditWishlistError(e.toString()));
 }
 }
}