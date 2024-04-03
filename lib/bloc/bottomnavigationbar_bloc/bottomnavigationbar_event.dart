import 'package:equatable/equatable.dart';

abstract class BottomNavigationEvent extends Equatable {
  const BottomNavigationEvent();

  @override
  List<Object> get props => [];
}

class BottomNavigationItemTapped extends BottomNavigationEvent {
  final int index;

  const BottomNavigationItemTapped(this.index);

  @override
  List<Object> get props => [index];
}
