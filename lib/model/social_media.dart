import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tobeto_app/widget/profile_widgets/custom_socialmedia_dropdown.dart';

// Sosyal medya seçeneklerini tanımlayın
List<SocialMedia> socialMediaOptions = [
  SocialMedia(name: 'Twitter'),
  SocialMedia(name: 'Facebook'),
  SocialMedia(name: 'Instagram'),
  SocialMedia(name: 'Github'),
  SocialMedia(name: 'Medium'),
  SocialMedia(name: 'Facebook'),
];

class SocialMediaTab extends StatefulWidget {
  @override
  _SocialMediaTabState createState() => _SocialMediaTabState();
}

class _SocialMediaTabState extends State<SocialMediaTab> {
  TextEditingController _socialMediaLinkController = TextEditingController();
  SocialMedia? selectedMedia;

  @override
  void initState() {
    super.initState();
    // İlk sosyal medya seçeneğini başlangıç değeri olarak ayarlayın
    selectedMedia = socialMediaOptions.first;
  }

  Future<void> _saveSocialMediaToFirestore() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı girişi yapılmamış.");
      return;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore
        .collection('users')
        .doc(userId)
        .collection('socialMedia')
        .add({
      'platform': selectedMedia?.name,
      'link':
          'https://www.${selectedMedia?.name.toLowerCase()}.com/${_socialMediaLinkController.text}',
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sosyal medya bilgileri kaydedildi.')));

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomSocialMediaDropdown(
            labelText: 'Sosyal Medya Seçiniz',
            selectedSocialMedia: selectedMedia,
            options: socialMediaOptions,
            onChanged: (SocialMedia? newValue) {
              setState(() {
                selectedMedia = newValue;
              });
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _socialMediaLinkController,
            decoration: InputDecoration(
              labelText: 'Sosyal Medya Kullanıcı Adı',
              hintText: 'Kullanıcı Adı',
              prefixText:
                  'https://www.${selectedMedia?.name.toLowerCase()}.com/',
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveSocialMediaToFirestore,
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
