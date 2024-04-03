import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tobeto_app/screen/bottomnavigationbar.dart';
import 'package:tobeto_app/screen/loginscreen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _checkWelcomeScreenVisibility();
  }

  void _checkWelcomeScreenVisibility() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showWelcomeScreen = prefs.getBool('showWelcomeScreen') ?? true;
    if (!showWelcomeScreen) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    FirebaseAuth.instance.authStateChanges().first.then((user) {
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => BottomNavigationBarScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  void _updateWelcomeScreenVisibility() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('showWelcomeScreen', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/splashscreen.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            top: 75,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _navigateToNextScreen();
                  _updateWelcomeScreenVisibility();
                },
                child: Text(
                  "Hadi Başlayalım",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
