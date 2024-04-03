import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CertificateTab extends StatefulWidget {
  @override
  _CertificateTabState createState() => _CertificateTabState();
}

class _CertificateTabState extends State<CertificateTab> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    // Tarayıcıdan dosya seçme desteği ile
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        _selectedFile = File(file.path!);
      });
    }
  }

  Future<void> _saveCertificatesToFirestore() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || _selectedFile == null) {
      print("Kullanıcı girişi yapılmamış veya dosya seçilmemiş.");
      return;
    }

    // Firebase Storage'a dosya yükleme
    String filePath =
        'certificates/$userId/${_selectedFile!.path.split('/').last}';
    Reference storageReference = FirebaseStorage.instance.ref().child(filePath);

    UploadTask uploadTask = storageReference.putFile(_selectedFile!);
    await uploadTask.whenComplete(() async {
      String downloadURL = await storageReference.getDownloadURL();

      // Firestore'a sertifika URL'sini kaydet
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('certificates')
          .add({
        'certificateURL': downloadURL,
        'uploadedAt': Timestamp.now(),
      });
    }).catchError((e) {
      print("Sertifika yükleme hatası: $e");
    });

    // Başarılı kayıt sonrası kullanıcıyı önceki sayfaya yönlendir
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Sertifikalarım',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            onPressed: _pickFile,
            child: Text("Dosya Seç",
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
          SizedBox(height: 20),
          _selectedFile != null
              ? Text("Seçilen Dosya: ${_selectedFile!.path}")
              : Text("Henüz dosya seçilmedi."),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                onPressed: () {
                  _saveCertificatesToFirestore();
                },
                child: Text(
                  "Kaydet",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
