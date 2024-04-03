import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeBloc {
  final _userNameController = StreamController<String?>.broadcast();
  Stream<String?> get userNameStream => _userNameController.stream;

  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      _userNameController.sink.add(userData.data()?['username'] ?? user.displayName ?? 'Kullanıcı Adı');
    }
  }

  void dispose() {
    _userNameController.close();
  }
}
