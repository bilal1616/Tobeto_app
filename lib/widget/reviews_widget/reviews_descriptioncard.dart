import 'package:flutter/material.dart';

class Reviewsdescriptioncard extends StatefulWidget {
  const Reviewsdescriptioncard({Key? key}) : super(key: key);

  @override
  _ReviewsdescriptioncardState createState() => _ReviewsdescriptioncardState();
}

class _ReviewsdescriptioncardState extends State<Reviewsdescriptioncard> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      children: [
        _buildCard(
          context,
          'Kazanım Odaklı Testler',
          'Dijital gelişim kategorisindeki \neğitimlere başlamadan \nönce'
              ' konuyla ilgili bilgin ölçülür \nve seviyene göre yönlendirilirsin.',
          false, // İlk kart için özel metin yok
        ),
        _buildCard(
          context,
          'Huawei Talent Interview \nTeknik Bilgi Sınavı*',
          'Sertifika alabilmen için,\neğitim yolculuğunun sonunda\n'
              'teknik yetkinliklerin\nve kod bilgin ölçülür.\n\n\n'
              '4400+ soru | \n30+ programlama dili\n 4 zorluk seviyesi\n\n',
          true, // İkinci kart için özel metin var
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, String title, String description,
      bool includeSpecialText) {
    double cardWidth = MediaQuery.of(context).size.width * 0.9;

    return Card(
      margin: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(0),
          topRight: const Radius.circular(20),
          bottomLeft: const Radius.circular(30),
          bottomRight: const Radius.circular(30),
        ),
      ),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(0),
            topRight: const Radius.circular(20),
            bottomLeft: const Radius.circular(30),
            bottomRight: const Radius.circular(30),
          ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 17, color: Colors.white),
                  children: [
                    TextSpan(text: description),
                    if (includeSpecialText)
                      const TextSpan(
                        text:
                            '\n*Türkiye Ar-Ge Merkezi tarafından tasarlanmıştır.',
                        style: TextStyle(fontSize: 13),
                      ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04)
            ],
          ),
        ),
      ),
    );
  }
}
