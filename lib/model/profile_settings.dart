import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tobeto_app/widget/profile_widgets/custom_date_picker.dart';
import 'package:tobeto_app/widget/profile_widgets/custom_text_field.dart';

List<String> cityList = <String>[
  'İstanbul',
  'İzmir',
  'Ankara',
  'Bursa',
  'Kocaeli'
];

class ProfilTab extends StatefulWidget {
  @override
  _ProfilTabState createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _tcController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _districtController = TextEditingController();
  TextEditingController _socialMediaController = TextEditingController();
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _newPasswordAgainController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _birthDateController = TextEditingController();

  DateTime? _selectedBirthDate;
  String _selectedCity = cityList.first;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImage(),
            CompCustomTextField(
              obscureText: false,
              controller: _nameController,
              helperText: 'Adınız',
              hintText: 'Adınızı girin',
            ),
            CompCustomTextField(
              obscureText: false,
              controller: _surnameController,
              helperText: "Soyadınız",
              hintText: 'Soyadınızı girin',
            ),
            CompCustomTextField(
              obscureText: false,
              controller: _phoneController,
              helperText: 'Telefon Numaranız',
              hintText: 'Telefon numaranızı girin',
            ),
            _buildDateTextField(),
            CompCustomTextField(
              obscureText: false,
              controller: _tcController,
              helperText: "T.C kimlik  numaranız",
              hintText: 'T.C kimlik no girin',
            ),
            CompCustomTextField(
              obscureText: false,
              controller: _emailController,
              helperText: "E-mail",
              hintText: 'E-mail girin',
            ),
            CompCustomTextField(
              obscureText: false,
              controller: _countryController,
              helperText: "Ülke",
              hintText: 'Ülkenizi girin',
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Şehir",
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
                      value: _selectedCity,
                      decoration: InputDecoration(
                        hintText: _selectedCity,
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
                          _selectedCity = value!;
                        });
                      },
                      items: cityList
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
                    _saveProfileToFirestore();
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

  Widget _buildDateTextField() {
    return DatePickerTextField(
      controller: _birthDateController,
      labelText: 'Doğum Tarihiniz',
      onDateSelected: (DateTime selectedBirthDate) {},
    );
  }

  Widget _buildImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 80,
          backgroundImage: _image != null ? FileImage(_image!) : null,
          child: _image == null
              ? Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
        PopupMenuButton<ImageSource>(
          onSelected: _pickImage,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ImageSource.camera,
              child: Text('Kameradan Çek'),
            ),
            PopupMenuItem(
              value: ImageSource.gallery,
              child: Text('Galeriden Seç'),
            ),
          ],
          icon: Icon(Icons.camera_alt_rounded,
              color: Theme.of(context).hintColor, size: 40),
        ),
      ],
    );
  }

  void _saveProfileToFirestore() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Kullanıcı profil bilgilerini 'profiles' alt koleksiyonuna kaydediyoruz.
    final DocumentReference profileDocRef = firestore
        .collection('users')
        .doc(userId)
        .collection('profiles')
        .doc('mainProfile');

    Map<String, dynamic> profileData = {
      'name': _nameController.text,
      'surname': _surnameController.text,
      'phone': _phoneController.text,
      'birthdate': _birthDateController.text.trim(),
      'tc': _tcController.text,
      'email': _emailController.text,
      'country': _countryController.text,
      'city': _selectedCity,
      // Diğer profil alanları buraya eklenebilir.
    };

    // Profil bilgilerini Firestore'a kaydet
    await profileDocRef.set(profileData, SetOptions(merge: true));

    // Profil resmini Firebase Storage'a kaydet ve URL'yi Firestore'a kaydet
    if (_image != null) {
      String fileName = 'profilePictures/${userId}.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      await storageReference.putFile(_image!);
      String downloadURL = await storageReference.getDownloadURL();
      // 'mainProfile' belgesini güncelleyerek profil resmi URL'sini ekleyin
      await profileDocRef.update({'profilePictureURL': downloadURL});
    }

    // Başarılı kayıt sonrası işlemler: Profil sayfasına yönlendir ve verileri yenile
    Navigator.pop(
        context, true); // true, başarılı bir kayıt işlemi yapıldığını belirtir.
  }
}
