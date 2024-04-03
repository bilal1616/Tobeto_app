// catalog_state.dart

import 'package:equatable/equatable.dart';
import 'package:tobeto_app/widget/catalog_widget/catalog_data.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final List<CatalogModel> catalogItems;

  const CatalogLoaded(this.catalogItems);

  @override
  List<Object?> get props => [catalogItems];
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}
