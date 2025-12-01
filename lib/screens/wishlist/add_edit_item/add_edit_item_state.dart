import 'package:equatable/equatable.dart';

abstract class AddEditItemState extends Equatable {
  const AddEditItemState();
  @override List<Object?> get props => [];
}
class AddEditItemInitial extends AddEditItemState {}
class AddEditItemLoading extends AddEditItemState {}
class AddEditItemSuccess extends AddEditItemState {}
class AddEditItemError extends AddEditItemState {
  final String message;
  const AddEditItemError(this.message);
}