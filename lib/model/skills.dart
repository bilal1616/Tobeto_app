import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tobeto_app/widget/profile_widgets/custom_skills_dropdown.dart';


List<String> skillsList = [
  'C#',
  'Dart / Flutter',
  'SQL',
  'Muhasebe',
  'Javascript',
  'Aktif Öğrenme',
  'Aktif Dinleme',
  'Uyum Sağlama',
  'Yönetim ve İdare',
  'Reklam',
  'Algoritmalar',
  'Android',
  'Mobil',
];

class SkillsTab extends StatefulWidget {
  @override
  _SkillsTabState createState() => _SkillsTabState();
}

class _SkillsTabState extends State<SkillsTab> {

  @override

  String _selectedSkill = skillsList.first;

  Skill? selectedSkill;

  final CollectionReference workCollection =
      FirebaseFirestore.instance.collection('work');
  final CollectionReference educationCollection =
      FirebaseFirestore.instance.collection('education');
  final CollectionReference skillsCollection =
      FirebaseFirestore.instance.collection('skills');
  final CollectionReference certificatesCollection =
      FirebaseFirestore.instance.collection('certificates');
  final CollectionReference socialMediaCollection =
      FirebaseFirestore.instance.collection('socialMedia');
  final CollectionReference languageCollection =
      FirebaseFirestore.instance.collection('languages');
  final CollectionReference settingsCollection =
      FirebaseFirestore.instance.collection('settings');

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
                  "Yetkinlikler",
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 57.0,
                  child: DropdownButtonFormField<String>(
                    value: _selectedSkill,
                    decoration: InputDecoration(
                      hintText: _selectedSkill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSkill = value!;
                      });
                    },
                    items: skillsList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
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
                  _saveSkillsToFirestore();
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

  void _saveSkillsToFirestore() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı girişi yapılmamış.");
      return;
    }
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // `skills` yerine, `users` koleksiyonu altındaki `userId` ile belirtilen kullanıcıya ve onun `skills` alt koleksiyonuna erişim sağla
    await firestore.collection('users').doc(userId).collection('skills').add({
      'skills': _selectedSkill,
    });

    // Başarılı kayıt sonrası kullanıcıyı önceki sayfaya yönlendir
    Navigator.pop(context, true);
  }
}
