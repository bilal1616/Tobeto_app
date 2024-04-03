import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tobeto_app/bloc/bottomnavigationbar_bloc/bottomnavigationbar_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore eklenmeli
import 'package:tobeto_app/screen/calendar.dart';
import 'package:tobeto_app/screen/catalog.dart';
import 'package:tobeto_app/screen/floatactionmenu.dart';
import 'package:tobeto_app/screen/homescreen.dart';
import 'package:tobeto_app/screen/loginscreen.dart';

import 'package:tobeto_app/screen/profile.dart';
import 'package:tobeto_app/screen/reviews.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({Key? key}) : super(key: key);

  @override
  _BottomNavigationBarScreenState createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  late BottomNavigationBloc _bloc;

  final List<Widget> _pages = [
    const HomeScreen(),
    const Reviews(),
    const ProfilePage(),
    const Catalog(),
    const CalendarPage(),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = BottomNavigationBloc();
    _loadUsername(); // Kullanıcı adını yükle
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    if (index < 5) {
      _bloc.mapEventToState(BottomNavigationEvent.SelectPage, index);
    } else {
      _showMoreOptions();
    }
  }

  void _showMoreOptions() {
    _loadUsername(); // Kullanıcı adını yükle

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Tobeto'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: StreamBuilder<String?>(
                stream: _bloc.usernameStream,
                initialData: 'Kullanıcı Adı',
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? 'Kullanıcı Adı');
                },
              ),
              onTap: () => _showProfileMenu(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Ana Menü'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Profil Bilgileri'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Oturumu Kapat'),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                final GoogleSignIn googleSignIn = GoogleSignIn();
                if (await googleSignIn.isSignedIn()) {
                  await googleSignIn.signOut();
                }
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> Route) => false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Önceki Sayfa'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  // _BottomNavigationBarScreenState sınıfındaki değişiklikler
  void _loadUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String? username;
      if (userDocSnapshot.exists &&
          userDocSnapshot.data()!.containsKey('username')) {
        username = userDocSnapshot.data()!['username'];
      } else {
        username = user.displayName;
      }

      _bloc.setUsername(
          username); // Kullanıcı adını _bloc içindeki Stream'e aktar
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    String imagePath =
        isDarkMode ? "assets/tobeto-logo-dark.png" : "assets/tobeto-logo.png";
    Color? iconColor = isDarkMode
        ? Theme.of(context).iconTheme.color
        : Theme.of(context).iconTheme.color;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          imagePath,
          width: 120,
          height: 60,
        ),
      ),
      body: StreamBuilder<int>(
        stream: _bloc.selectedPageStream,
        initialData: 0,
        builder: (context, snapshot) {
          return _pages[snapshot.data ?? 0];
        },
      ),
      floatingActionButton: const FloatingActionMenuButton(),
      bottomNavigationBar: StreamBuilder<int>(
        stream: _bloc.selectedPageStream,
        initialData: 0,
        builder: (context, snapshot) {
          return BottomNavigationBar(
            onTap: _selectPage,
            currentIndex: snapshot.data ?? 0,
            selectedItemColor: Theme.of(context).iconTheme.color,
            unselectedItemColor: Theme.of(context).iconTheme.color,
            selectedLabelStyle:
                TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: iconColor),
                label: 'Anasayfa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star, color: iconColor),
                label: 'Değerlendirmeler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: iconColor),
                label: 'Profil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book, color: iconColor),
                label: 'Katalog',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today, color: iconColor),
                label: 'Takvim',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz, color: iconColor),
                label: 'Daha Fazla',
              ),
            ],
          );
        },
      ),
    );
  }
}
