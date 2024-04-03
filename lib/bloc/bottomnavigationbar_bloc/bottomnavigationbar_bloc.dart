import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum BottomNavigationEvent { LoadUsername, SelectPage }

class BottomNavigationBloc {
  final _usernameController = StreamController<String?>.broadcast(); // StreamController tanımla
  final _selectedPageController = StreamController<int>.broadcast();

  Stream<String?> get usernameStream => _usernameController.stream; // Kullanıcı adı değişikliklerini dinle
  Stream<int> get selectedPageStream => _selectedPageController.stream;

  void dispose() {
    _usernameController.close();
    _selectedPageController.close();
  }

  void setUsername(String? username) {
    _usernameController.add(username); // Kullanıcı adı değiştiğinde bu Stream'e veri ekle
  }

  void mapEventToState(BottomNavigationEvent event, int index) async {
    if (event == BottomNavigationEvent.LoadUsername) {
      await _loadUsername();
    } else if (event == BottomNavigationEvent.SelectPage) {
      _selectedPageController.sink.add(index);
    }
  }

  Future<void> _loadUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String? username;
      if (userDocSnapshot.exists &&
          userDocSnapshot.data()!.containsKey(username)) {
        username = userDocSnapshot.data()![username];
      } else {
        username = user.displayName;
      }

      _usernameController.sink.add(username); // Bu kısmı değiştirdik
    }
  }
}
