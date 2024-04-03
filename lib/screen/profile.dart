import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tobeto_app/model/work_experience.dart';
import 'package:tobeto_app/screen/profil_edit.dart';
import 'package:tobeto_app/widget/reviews_widget/view_report.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String name = "";
  late String surname = "";
  late String birthDate = "";
  late String email = "";
  late String phone = "";
  late String city = "";
  late String country = "";
  late String tc = "";
  late String skill = "";
  late String socialMedia = "";
  late String language = "";
  late String education = "";
  late String work = "";
  late String profilePictureURL = "";
  late String certificateURL = "";
  // Diğer değişken tanımlamalarınızın altına bu listeyi ekleyin
  List<String> userSkills = [];
  late List<Map<String, String>> socialMediaLinks = [];
  // Sınıfın üstünde bir state değişkeni olarak tanımlayın
  List<WorkExperience> workExperiences = [];

  @override
  void initState() {
    super.initState();
    fetchUserProfileData();
    fetchUserWorkData();
    fetchUserEducationData();
    fetchUserSkills();
    fetchUserCertificates();
    fetchUserSocialMediaLinks();
    fetchUserLanguageData();
  }

  Future<void> fetchUserProfileData() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final QuerySnapshot<Map<String, dynamic>> profileSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('profiles')
            .get();

    if (profileSnapshot.docs.isNotEmpty) {
      final Map<String, dynamic> userProfile =
          profileSnapshot.docs.first.data();

      setState(() {
        name = userProfile['name'] ?? '';
        surname = userProfile['surname'] ?? '';
        birthDate = userProfile['birthdate'] ?? '';
        email = userProfile['email'] ?? '';
        phone = userProfile['phone'] ?? '';
        city = userProfile['city'] ?? '';
        country = userProfile['country'] ?? '';
        tc = userProfile['tc'] ?? '';
        profilePictureURL = userProfile['profilePictureURL'] ?? '';
      });
    }
  }

  Future<void> fetchUserSkills() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı girişi yapılmamış.");
      return;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot skillSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('skills')
        .get();

    List<String> fetchedSkills = [];
    for (var doc in skillSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String skill = data['skills'] ?? 'Bilinmeyen Yetenek';
      fetchedSkills.add(skill);
    }

    // UI'da göstermek üzere yetenek listesini güncelle
    setState(() {
      userSkills = fetchedSkills; // skillsList yerine userSkills kullanın
    });
  }

  Future<void> fetchUserWorkData() async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("Kullanıcı girişi yapılmamış.");
      }
      // Firestore'dan kullanıcının iş deneyimlerini çek
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('workExperiences')
              .get();

      // Firestore'dan çekilen verileri WorkExperience modeline dönüştür ve listeyi güncelle
      final List<WorkExperience> newWorkExperiences =
          querySnapshot.docs.map((doc) {
        return WorkExperience.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      // UI'da göstermek üzere state güncelleme
      setState(() {
        workExperiences = newWorkExperiences;
        // Her bir iş deneyimi için detaylı bir açıklama oluştur
        work = workExperiences
            .map((e) =>
                '${e.company}\n${e.position}\n${e.sector}\n${e.startDate}\n${e.endDate}\n${e.city}\n${e.description}')
            .join('');
      });
    } catch (e) {
      print('Error fetching user work data: $e');
    }
  }

  Future<void> fetchUserEducationData() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("User ID is null. Cannot fetch education data.");
      return;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot educationSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('education')
        .get();

    String fetchedEducation = "";

    if (educationSnapshot.docs.isNotEmpty) {
      for (var doc in educationSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String university = data['university'] ?? 'Unknown University';
        String section = data['section'] ?? 'Unknown Section';
        String educationStatus = data['educationStatus'] ?? 'Unknown Status';
        String startDate = data['startDate'] ?? 'Unknown Start Date';
        String graduateDate = data['graduateDate'] ?? 'Unknown Graduate Date';

        fetchedEducation +=
            "$university\n$section\n$educationStatus\n$startDate - $graduateDate\n";
      }

      setState(() {
        education = fetchedEducation;
      });
    }
  }

  Future<void> fetchUserLanguageData() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("User ID is null. Cannot fetch language data.");
      return;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Kullanıcının kaydettiği dilleri çekiyoruz.
    final QuerySnapshot languageSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('languages')
        .get();

    List<String> languages = [];
    languageSnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String language = data['language'] ?? '';
      String level = data['level'] ?? '';
      languages.add("$language ($level)");
    });

    // UI'da göstermek üzere dilleri ve seviyeleri birleştirilmiş string olarak güncelle
    setState(() {
      language = languages.join('\n');
    });
  }

  Future<void> fetchUserCertificates() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı girişi yapılmamış.");
      return;
    }

    final QuerySnapshot certificateSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('certificates')
        .orderBy('uploadedAt', descending: true)
        .get();

    List<String> certificateURLs = certificateSnapshot.docs.map((doc) {
      // Hatanın giderilmesi için ek açıklık
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['certificateURL'] as String;
    }).toList();

    setState(() {
      // Hata nedeniyle mevcut olmayabilir, control eklenmeli
      certificateURL = certificateURLs.isNotEmpty ? certificateURLs.first : '';
    });
  }

  Widget _buildCertificateSection() {
    return certificateURL.isNotEmpty
        ? Image.network(certificateURL)
        : Text("Henüz bir sertifika yüklenmedi.");
  }

  Future<void> fetchUserSocialMediaLinks() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final QuerySnapshot<Map<String, dynamic>> socialMediaSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('socialMedia')
            .get();

    // Her bir dokümanı Map<String, String> olarak dönüştür
    List<Map<String, String>> links = socialMediaSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      // Veriyi Map<String, String> olarak dönüştür
      return {
        "platform":
            data['platform'] is String ? data['platform'] as String : 'Unknown',
        "link": data['link'] is String ? data['link'] as String : '',
      };
    }).toList();

    setState(() {
      socialMediaLinks = links;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildIcons(),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: screenHeight / 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColorDark,
                                  Theme.of(context).primaryColor,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: profilePictureURL.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        profilePictureURL,
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Color(0xFF41528f),
                                      radius: 80,
                                      child: Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Color(0xFF9e91f0),
                                      )),
                            ),
                          ),
                          SizedBox(height: 40),
                          _buildPersonalInfo("Ad Soyad", "$name $surname",
                              "assets/cv-name.png"),
                          SizedBox(height: 10),
                          _buildPersonalInfo(
                              "Doğum Tarihi", birthDate, "assets/cv-date.png"),
                          SizedBox(height: 10),
                          _buildPersonalInfo(
                              "E-mail", email, "assets/cv-mail.png"),
                          SizedBox(height: 10),
                          _buildPersonalInfo(
                              "Telefon", phone, "assets/cv-phone.png"),
                          _buildPersonalInfo("Şehir", city, "assets/city.png"),
                          _buildPersonalInfo(
                              "Ülke", country, "assets/country.png"),
                          _buildPersonalInfo(
                              "TC Kimlik No", tc, "assets/tc.png"),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 210,
                      right: 10,
                      child: ElevatedButton(
                        onPressed: () {
                          // Silme işlemi için onay modalı göster
                          _showDeleteConfirmationModal();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.delete), // Silme ikonu
                            SizedBox(width: 3), // İkon ile metin arasına boşluk
                            Text('Bilgileri Sil'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildContainerWithTitle("Yetkinliklerim", userSkills.join("\n")),
              _buildContainerWithTitle("Yabancı Dillerim", language),
              _buildContainerWithCertificate("Sertifikalarım", certificateURL),
              _buildSocialMediaContainer("Medya Hesaplarım", socialMediaLinks),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tobeto İşte Başarı Modelim',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.remove_red_eye_outlined)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          height: 1,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                "İşte Başarı Modeli değerlendirmesiyle Yetkinliklerini Ölç "),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewReport()),
                                );
                              },
                              child: Text(
                                'Başla',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildContainerWithAsset(),
              _buildContainerWithTitle("Eğitim Hayatı", education),
              _buildContainerWithTitle("Deneyimlerim", work),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcons() {
    return Padding(
      padding: const EdgeInsets.only(right: 30, top: 45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
              onTap: () {
                // Profil düzenleme sayfasına yönlendir
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileInformation()))
                    .then((value) {
                  if (value == true) {
                    // Kullanıcı bilgilerini yeniden fetch et
                    fetchUserProfileData();
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 1, right: 10),
                child: Icon(Icons.edit_note),
              )),
          Icon(Icons.share_outlined),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(String name, String email, String assetPath) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        assetPath,
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          email,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bilgiyi Sil"),
          content: Text("Profil bilgilerini silmek istediğinize emin misiniz?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Hayır",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                // Silme işlemini gerçekleştir
                _deleteProfileInfo();
                Navigator.of(context).pop();
              },
              child: Text(
                "Evet",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProfileInfo() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı girişi yapılmamış.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('profiles')
          .doc('mainProfile')
          .delete(); // Tüm ana profil belgesini sil

      // Bilgi başarıyla silindiğinde UI'ı güncelle
      setState(() {
        // Tüm alanları boşalt
        name = '';
        surname = '';
        birthDate = '';
        email = '';
        phone = '';
        city = '';
        country = '';
        tc = '';
        profilePictureURL = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil bilgileri başarıyla silindi.")),
      );
    } catch (e) {
      print("Hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil bilgileri silinirken bir hata oluştu.")),
      );
    }
  }

  Widget _buildContainerWithTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Silme işlemi için onay modalı göster
                    _showDeleteConfirmationModalAll(title);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.delete), // Silme ikonu
                      SizedBox(width: 3), // İkon ile metin arasına boşluk
                      Text('Bilgileri Sil'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationModalAll(String fieldName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bilgiyi Sil"),
          content:
              Text("'$fieldName' bilgisini silmek istediğinize emin misiniz?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Hayır",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteProfileInfoAll(fieldName);
                Navigator.of(context).pop();
              },
              child: Text(
                "Evet",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProfileInfoAll(String fieldName) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı girişi yapılmamış.");
      return;
    }

    try {
      // Silinecek alanın collection içindeki belirli bir dokümanını silebilirsiniz
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(fieldName == 'Yetkinliklerim'
              ? 'skills'
              : fieldName == 'Yabancı Dillerim'
                  ? 'languages'
                  : fieldName == 'Eğitim Hayatı'
                      ? 'education'
                      : 'workExperiences')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // Bilgi başarıyla silindiğinde UI'ı güncelle
      setState(() {
        if (fieldName == 'Hakkımda') {
          // Silme işlemi yapmak istemiyorsanız bu bloğu silebilirsiniz
        } else if (fieldName == 'Yetkinliklerim') {
          userSkills.clear();
        } else if (fieldName == 'Yabancı Dillerim') {
          language = '';
        } else if (fieldName == 'Eğitim Hayatı') {
          education = '';
        } else if (fieldName == 'Deneyimlerim') {
          workExperiences.clear();
          work = '';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("'$fieldName' bilgisi başarıyla silindi.")),
      );
    } catch (e) {
      print("Hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("'$fieldName' bilgisi silinirken bir hata oluştu.")),
      );
    }
  }

  Widget _buildContainerWithAsset() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Ödüllerim",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/rozet1.jpg', height: 125, width: 150),
                  SizedBox(width: 20),
                  Image.asset('assets/rozet2.jpg', height: 125, width: 150),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerWithCertificate(String title, String certificateURL) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Silme işlemi için onay modalı göster
                    _showDeleteConfirmationModalCertificate(title);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.delete), // Silme ikonu
                      SizedBox(width: 3), // İkon ile metin arasına boşluk
                      Text('Bilgileri Sil'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  certificateURL.isNotEmpty
                      ? Center(
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 6,
                            child: Image.network(
                              certificateURL,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      : Center(
                          child: Text("Henüz bir sertifika eklemediniz."),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationModalCertificate(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sertifika Sil"),
          content:
              Text("'$title' sertifikasını silmek istediğinize emin misiniz?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Hayır",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteCertificate(title);
                Navigator.of(context).pop();
              },
              child: Text(
                "Evet",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCertificate(String title) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı girişi yapılmamış.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('certificates')
          .where('title', isEqualTo: title)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // Bilgi başarıyla silindiğinde UI'ı güncelle
      setState(() {
        certificateURL = ''; // Sertifika URL'sini temizle
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("'$title' sertifikası başarıyla silindi.")),
      );
    } catch (e) {
      print("Hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("'$title' sertifikası silinirken bir hata oluştu.")),
      );
    }
  }

  Widget _buildSocialMediaContainer(
      String title, List<Map<String, String>> links) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Silme işlemi için onay modalı göster
                    _showDeleteConfirmationModalSocial(title);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.delete), // Silme ikonu
                      SizedBox(width: 3), // İkon ile metin arasına boşluk
                      Text('Bilgileri Sil'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              width: double.infinity,
              height: 1,
              color: Colors.black,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: links.map((link) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  title: Text(
                    link['platform']!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    link['link']!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _launchURL(link['link']!),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationModalSocial(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hesap Sil"),
          content: Text("'$title' hesabını silmek istediğinize emin misiniz?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Hayır",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteSocialMediaAccount(title);
                Navigator.of(context).pop();
              },
              child: Text(
                "Evet",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSocialMediaAccount(String title) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Kullanıcı girişi yapılmamış.");
      return;
    }

    try {
      // Firebase'deki tüm sosyal medya hesaplarını sil
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('socialMedia')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // UI güncelleme ve liste boşaltma
      setState(() {
        socialMediaLinks.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tüm hesaplar başarıyla silindi.")),
      );
    } catch (e) {
      print("Hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hesaplar silinirken bir hata oluştu.")),
      );
    }
  }
}
