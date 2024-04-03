import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tobeto_app/bloc/login_bloc/login_bloc.dart';
import 'package:tobeto_app/screen/bottomnavigationbar.dart';
import 'package:tobeto_app/theme/app_color.dart';

final firebaseAuthInstance = FirebaseAuth.instance;
final firebaseFirestore = FirebaseFirestore.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _username = '';

  late final LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc();
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  void _submit() async {
    _formKey.currentState!.save();

    try {
      if (_loginBloc.isLogin) {
        // Giriş sayfası için işlemler
        final userCredentials = await firebaseAuthInstance
            .signInWithEmailAndPassword(email: _email, password: _password);
        print(userCredentials);
      } else {
        // Kayıt sayfası için işlemler
        final userCredentials = await firebaseAuthInstance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        await firebaseFirestore
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set({'email': _email, 'username': _username});
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BottomNavigationBarScreen(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? "Giriş/Kayıt başarısız.")),
      );
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print(e);
      return null;
    }
  }

  // Mail adresiyle parola sıfırlama işlemi
  void _resetPassword(BuildContext context) async {
    TextEditingController emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Parolamı Unuttum"),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-posta',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Gönder"),
              onPressed: () async {
                String email = emailController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    await firebaseAuthInstance.sendPasswordResetEmail(
                        email: email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Parola sıfırlama e-postası gönderildi."),
                      ),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Parola sıfırlama e-postası gönderilirken bir hata oluştu."),
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Lütfen bir e-posta adresi girin."),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    String imagePath =
        isDarkMode ? "assets/tobeto-logo-dark.png" : "assets/tobeto-logo.png";
    String imagePath1 = isDarkMode ? "assets/siyah.png" : "assets/beyaz.png";
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              imagePath1,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.625,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(imagePath, width: 150, height: 75),
                        StreamBuilder<bool>(
                          stream: _loginBloc.isLoginStream,
                          initialData: true,
                          builder: (context, snapshot) {
                            return snapshot.data == true
                                ? SizedBox.shrink()
                                : TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "Kullanıcı Adı"),
                                    autocorrect: false,
                                    onSaved: (newValue) =>
                                        _username = newValue!,
                                  );
                          },
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: "E-posta"),
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (newValue) => _email = newValue!,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005),
                        TextFormField(
                          decoration: const InputDecoration(labelText: "Şifre"),
                          autocorrect: false,
                          obscureText: true,
                          onSaved: (newValue) => _password = newValue!,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text(_loginBloc.isLogin ? "Giriş Yap" : "Kayıt Ol"),
                        ),
                        TextButton(
                          onPressed: () => _loginBloc.toggleLogin(),
                          child: Text(_loginBloc.isLogin
                              ? "Kayıt Sayfasına Git"
                              : "Giriş Sayfasına Git"),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                UserCredential? userCredential =
                                    await signInWithGoogle();
                                if (userCredential != null) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BottomNavigationBarScreen(),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(FontAwesomeIcons.google,
                                  color: Colors.white),
                              label: Text("Google ile Giriş Yap"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppColor.favoriteButtonColor,
                                textStyle: TextStyle(color: Colors.white),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        const Divider(),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.009),
                        InkWell(
                          onTap: () {
                            _resetPassword(context);
                          },
                          child: const Text("Parolamı Unuttum"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
