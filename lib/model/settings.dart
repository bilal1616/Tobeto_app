import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tobeto_app/screen/loginscreen.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _newPasswordAgainController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _deleteUserAndSubcollections() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hesabı Sil"),
        content: Text("Hesabınızı silmek istediğinize emin misiniz?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Hayır"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Evet"),
          ),
        ],
      ),
    );

    if (confirmDelete != null && confirmDelete) {
      User? user = _auth.currentUser;
      if (user != null) {
        final String userUid = user.uid;

        // Firestore'daki kullanıcı verileri ve alt koleksiyonları sil
        await deleteUserAndSubcollections(userUid);

        // Firebase Storage'daki kullanıcı dosyalarını sil
        await deleteUserStorageFiles(userUid);

        // Kullanıcının Firebase Authentication üyeliğini sil
        await user.delete();

        // Kullanıcının oturumunu kapat
        await _auth.signOut();

        // Kullanıcıyı giriş ekranına yönlendir
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  Future<void> deleteUserAndSubcollections(String userUid) async {
    List<String> subcollections = [
      'certificates',
      'education',
      'languages',
      'profiles',
      'skills',
      'socialMedia',
      'workExperiences'
    ];

    try {
      for (String collection in subcollections) {
        var documentsSnapshot = await _firestore
            .collection('users')
            .doc(userUid)
            .collection(collection)
            .get();

        for (var doc in documentsSnapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Ana kullanıcı belgesini sil
      await _firestore.collection('users').doc(userUid).delete();
    } catch (e) {
      print("Firestore'da kullanıcı ve alt koleksiyonları silerken hata: $e");
    }
  }

  Future<void> deleteUserStorageFiles(String userUid) async {
    try {
      // Profil resmini sil
      await _storage.ref('profilePictures/$userUid.jpg').delete();

      // Sertifikaları sil
      final ListResult result =
          await _storage.ref('certificates/$userUid').listAll();
      for (var file in result.items) {
        await file.delete();
      }
    } catch (e) {
      print("Storage'da dosyaları silerken hata: $e");
    }
  }

  void _changePassword() async {
    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    String newPasswordAgain = _newPasswordAgainController.text;

    if (newPassword != newPasswordAgain) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Yeni şifreler uyuşmuyor."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    User? user = _auth.currentUser;
    AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!, password: oldPassword);

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Şifre başarıyla güncellendi."),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Şifre güncellenirken bir hata oluştu: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              _buildPasswordField("Eski Şifre", _oldPasswordController),
              _buildPasswordField("Yeni Şifre", _newPasswordController),
              _buildPasswordField(
                  "Yeni Şifre Tekrar", _newPasswordAgainController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text("Şifreyi Değiştir"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteUserAndSubcollections,
                child:
                    Text("Hesabı Sil", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
