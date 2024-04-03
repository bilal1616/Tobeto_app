// catalog_bloc.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tobeto_app/bloc/catalog_bloc/catalog_event.dart';
import 'package:tobeto_app/bloc/catalog_bloc/catalog_state.dart';
import 'package:tobeto_app/widget/catalog_widget/catalog_data.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CatalogBloc() : super(CatalogLoading());

  Stream<CatalogState> mapEventToState(
    CatalogEvent event,
  ) async* {
    if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is PageChanged) {
      yield* _mapPageChangedToState(event);
    }
  }

  Stream<CatalogState> _mapSearchTextChangedToState(
    SearchTextChanged event,
  ) async* {
    final searchText = event.searchText.trim().toLowerCase();

    yield CatalogLoading();

    try {
      final snapshot = await _firestore.collection('catalog-card').get();

      final catalogItems = snapshot.docs
          .map((doc) => CatalogModel(
                id: doc.id,
                imagePath: doc['imageUrl'],
                name: doc['instructor'],
                time: doc['time'],
                title: doc['title'],
                videoURL: doc['videoURL'],
              ))
          .where((item) =>
              item.name.toLowerCase().contains(searchText) ||
              item.title.toLowerCase().contains(searchText))
          .toList();

      yield CatalogLoaded(catalogItems);
    } catch (e) {
      yield CatalogError('Failed to load catalog: $e');
    }
  }

  Stream<CatalogState> _mapPageChangedToState(
    PageChanged event,
  ) async* {
    yield CatalogLoading();

    try {
      final snapshot = await _firestore.collection('catalog-card').get();

      final catalogItems = snapshot.docs
          .map((doc) => CatalogModel(
                id: doc.id,
                imagePath: doc['imageUrl'],
                name: doc['instructor'],
                time: doc['time'],
                title: doc['title'],
                videoURL: doc['videoURL'],
              ))
          .toList();

      yield CatalogLoaded(catalogItems);
    } catch (e) {
      yield CatalogError('Failed to load catalog: $e');
    }
  }
}
