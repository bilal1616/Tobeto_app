// catalog_event.dart

import 'package:equatable/equatable.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class SearchTextChanged extends CatalogEvent {
  final String searchText;

  const SearchTextChanged(this.searchText);

  @override
  List<Object?> get props => [searchText];
}

class PageChanged extends CatalogEvent {
  final int page;

  const PageChanged(this.page);

  @override
  List<Object?> get props => [page];
}
