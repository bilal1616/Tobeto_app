import 'package:equatable/equatable.dart';

abstract class BottomNavigationState extends Equatable {
  const BottomNavigationState();

  @override
  List<Object> get props => [];
}

class BottomNavigationInitial extends BottomNavigationState {}

class BottomNavigationIndexChanged extends BottomNavigationState {
  final int index;

  const BottomNavigationIndexChanged(this.index);

  @override
  List<Object> get props => [index];
}
