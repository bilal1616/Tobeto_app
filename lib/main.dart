import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tobeto_app/bloc/auth_bloc/authentication_bloc.dart';
import 'package:tobeto_app/bloc/auth_bloc/authentication_event.dart';
import 'package:tobeto_app/bloc/auth_bloc/authentication_state.dart';
import 'package:tobeto_app/firebase_options.dart';
import 'package:tobeto_app/screen/bottomnavigationbar.dart';
import 'package:tobeto_app/screen/loginscreen.dart';
import 'package:tobeto_app/screen/welcomepage.dart';
import 'package:tobeto_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc()..add(AppStarted()),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationUninitialized) {
              return LoginScreen(); // Başlangıç ekranı
            } else if (state is AuthenticationAuthenticated) {
              return WelcomePage(); // Giriş yapıldıysa ana sayfa
            } else {
              return BottomNavigationBarScreen(); // Giriş yapılmadıysa giriş sayfası
            }
          },
        ),
      ),
    );
  }
}
