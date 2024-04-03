import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tobeto_app/widget/profile_widgets/custom_date_picker.dart';
import 'package:tobeto_app/widget/profile_widgets/custom_skills_dropdown.dart';
import 'package:tobeto_app/widget/profile_widgets/custom_socialmedia_dropdown.dart';
import 'package:tobeto_app/widget/profile_widgets/custom_text_field.dart';

List<String> educationList = <String>[
  'Lise',
  'Önlisans',
  'Lisans',
  'Yüksek Lisans',
  'Doktora'
];

class EductionTab extends StatefulWidget {
  @override
  _EductionTabState createState() => _EductionTabState();
}

class _EductionTabState extends State<EductionTab> {
  @override
  TextEditingController _universityController = TextEditingController();
  TextEditingController _sectionController = TextEditingController();

  TextEditingController _startEducationDateController = TextEditingController();

  TextEditingController _graduateDateController = TextEditingController();

  DateTime? _selectedStartEducationDate;
  DateTime? _selectedEndEducationDate;
  String _selectedEducation = educationList.first;

  Skill? selectedSkill;
  SocialMedia? selectedMedia;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CompCustomTextField(
              obscureText: false,
              controller: _universityController,
              helperText: 'Üniversite',
              hintText: 'Kampüs 365',
            ),
            CompCustomTextField(
              obscureText: false,
              controller: _sectionController,
              helperText: "Bölüm",
              hintText: 'Yazılım',
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Eğitim Durumu",
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
                      value: _selectedEducation,
                      decoration: InputDecoration(
                        hintText: _selectedEducation,
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
                          _selectedEducation = value!;
                        });
                      },
                      items: educationList
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
            _buildEducationStartDateTextField(),
            _buildGradudateDateTextField(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: () {
                    _saveEducationToFirestore();
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
      ),
    );
  }

  Widget _buildEducationStartDateTextField() {
    return DatePickerTextField(
      controller: _startEducationDateController,
      labelText: 'Başlangıç Tarihi',
      onDateSelected: (DateTime selectedStartEducationDate) {},
    );
  }

  Widget _buildGradudateDateTextField() {
    return DatePickerTextField(
      controller: _graduateDateController,
      labelText: 'Mezuniyet Tarihi',
      onDateSelected: (DateTime selectedEndEducationDate) {},
    );
  }

  Widget _buildEducationTab() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CompCustomTextField(
              obscureText: false,
              controller: _universityController,
              helperText: 'Üniversite',
              hintText: 'Kampüs 365',
            ),
            CompCustomTextField(
              obscureText: false,
              controller: _sectionController,
              helperText: "Bölüm",
              hintText: 'Yazılım',
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Eğitim Durumu",
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
                      value: _selectedEducation,
                      decoration: InputDecoration(
                        hintText: _selectedEducation,
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
                          _selectedEducation = value!;
                        });
                      },
                      items: educationList
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
            _buildEducationStartDateTextField(),
            _buildGradudateDateTextField(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: () {
                    _saveEducationToFirestore();
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
      ),
    );
  }

  void _saveEducationToFirestore() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // Handle the case where the user ID is not available
      print("User ID is null. Cannot save education data.");
      return;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Point to a subcollection named "education" under the current user's document
    final CollectionReference educationCollection =
        firestore.collection('users').doc(userId).collection('education');

    // Create a new document in the "education" subcollection
    await educationCollection.add({
      'university': _universityController.text,
      'section': _sectionController.text,
      'educationStatus': _selectedEducation,
      'startDate': _startEducationDateController.text.trim(),
      'graduateDate': _graduateDateController.text.trim(),
      // Include other relevant fields
    });

    // Başarılı kayıt sonrası kullanıcıyı önceki sayfaya yönlendir
    Navigator.pop(context, true);
  }
}
