import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

List<String> languageList = <String>[
  'Türkçe',
  'İngilizce',
  'Almanca',
  'İspanyolca',
  'Fransızca',
  'Rusça',
  'Japonca',
  'Portekizce',
];
List<String> languageLevelList = <String>[
  'Temel Seviye(A1-A2)',
  'Orta Seviye(B1-B2)',
  'İleri Seviye(C1-C2)',
  'Anadil'
];

class LanguageTab extends StatefulWidget {
  @override
  _LanguageTabState createState() => _LanguageTabState();
}

class _LanguageTabState extends State<LanguageTab> {
  @override
  String _selectedLanguage = languageList.first;
  String _selectedLanguageLevel = languageLevelList.first;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Yabancı Dil Seçin",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 57.0,
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      hintText: _selectedLanguage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                    items: languageList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Seviye Seçin",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 57.0,
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguageLevel,
                    decoration: InputDecoration(
                      hintText: _selectedLanguageLevel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedLanguageLevel = value!;
                      });
                    },
                    items: languageLevelList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                onPressed: () {
                  _saveLanguageToFirestore();
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

  void _saveLanguageToFirestore() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Kullanıcının dillerini 'languages' alt koleksiyonuna kaydediyoruz.
    await firestore
        .collection('users')
        .doc(userId)
        .collection('languages')
        .add({
      'language': _selectedLanguage,
      'level': _selectedLanguageLevel,
    });

    // Kullanıcıya bilgi vermek için snackbar gösterimi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dil bilgileri başarıyla kaydedildi.')),
    );

    // Kayıt sonrası önceki sayfaya dön
    Navigator.pop(context, true);
  }
}
