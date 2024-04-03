import 'package:flutter/material.dart';
import 'package:tobeto_app/bloc/homescreen_bloc/home_bloc.dart';
import 'package:tobeto_app/screen/catalog.dart';
import 'package:tobeto_app/screen/profil_edit.dart';
import 'package:tobeto_app/screen/reviews.dart';
import 'package:tobeto_app/widget/home_widget/announcementandnews.dart';
import 'package:tobeto_app/widget/home_widget/applications.dart';
import 'package:tobeto_app/widget/home_widget/education.dart';
import 'package:tobeto_app/widget/home_widget/examcard.dart';
import 'package:tobeto_app/widget/home_widget/gradient_buttons.dart';
import 'package:tobeto_app/widget/home_widget/surveys.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeBloc _bloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    _bloc.getCurrentUser();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                StreamBuilder<String?>(
                  stream: _bloc.userNameStream,
                  builder: (context, snapshot) {
                    return RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "TOBETO",
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "'ya hoş geldin \n${snapshot.data}",
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Text(
                  "Yeni nesil öğrenme deneyimi ile Tobeto kariyer yolculuğunda senin yanında!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        )
                      ]),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/ıstanbulkodluyortobeto.png",
                        width: 200,
                        height: 80,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        child: Text(
                          "Ücretsiz eğitimlerle, geleceğin mesleklerinde sen de yerini al.",
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "Aradığın ",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    Theme.of(context).colorScheme.background,
                              ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '"',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                            TextSpan(
                              text: "İş",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        Theme.of(context)
                                            .colorScheme
                                            .background,
                                  ),
                            ),
                            TextSpan(
                              text: '"',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                            TextSpan(
                              text: " Burada! ",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        Theme.of(context)
                                            .colorScheme
                                            .background,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      // Menü butonlarının olduğu kısım
                      _buildMenuButtonsSection(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                ExamCard(), // ExamCard'ı burada kullanıyoruz
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GradientButton(
                        text: 'Profilini oluştur',
                        onPressed: () {
                          // Profil oluşturma işlemi
                        },
                        onSecondaryPressed: () {
                          // 'Başla' butonuna basıldığında yapılacak işlem
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ProfileInformation()),
                          );
                        },
                        gradientColors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.secondary
                        ],
                      ),
                      SizedBox(height: 16), // Butonlar arası boşluk
                      GradientButton(
                        text: 'Kendini değerlendir',
                        onPressed: () {
                          // Kendini değerlendirme işlemi
                        },
                        onSecondaryPressed: () {
                          // 'Başla' butonuna basıldığında yapılacak işlem
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Reviews(showAppBar: true)),
                          );
                        },
                        gradientColors: [
                          Theme.of(context).primaryColorLight,
                          Theme.of(context).primaryColorDark
                        ],
                      ),
                      SizedBox(height: 16), // Butonlar arası boşluk
                      GradientButton(
                        text: 'Öğrenmeye başla',
                        onPressed: () {
                          // Öğrenmeye başlama işlemi
                        },
                        onSecondaryPressed: () {
                          // 'Başla' butonuna basıldığında yapılacak işlem
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Catalog(showAppBar: true)),
                          );
                        },
                        gradientColors: [
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).primaryColor
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButtonsSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Başlığı sola hizalama
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Bilgilendirme',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMenuButton(
                context,
                'Başvurularım',
                Applications(),
                Colors.lightBlue.shade200, // Pastel mavi renk
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.01), // Butonlar arası boşluk
              _buildMenuButton(
                context,
                'Eğitimlerim',
                EducationPage(),
                Colors.lightGreen.shade200, // Pastel yeşil renk
              ),
            ],
          ),
          SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.01), // Dikey boşluk
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMenuButton(
                context,
                'Duyuru ve Haberlerim',
                AnnouncementAndNews(),
                Colors.pink.shade200, // Pastel pembe renk
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.01), // Butonlar arası boşluk
              _buildMenuButton(
                context,
                'Anketlerim',
                Surveys(),
                Colors.orange.shade200, // Pastel turuncu renk
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, String title, Widget page, Color bgColor) {
    double width = MediaQuery.of(context).size.width / 2.15 - 10;
    double height = width / 1.75;

    return Container(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.background),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: bgColor, // Farklı renkler kullanıldı
        ),
      ),
    );
  }
}
