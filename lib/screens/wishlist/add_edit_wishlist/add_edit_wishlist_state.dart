import 'package:equatable/equatable.dart';

abstract class AddEditWishlistState extends Equatable {
  const AddEditWishlistState();
  @override List<Object?> get props => [];
}

class AddEditWishlistInitial extends AddEditWishlistState {}
class AddEditWishlistLoading extends AddEditWishlistState {}
class AddEditWishlistSuccess extends AddEditWishlistState {}
class AddEditWishlistError extends AddEditWishlistState {
  final String message;
  const AddEditWishlistError(this.message);
  @override List<Object?> get props => [message];
}