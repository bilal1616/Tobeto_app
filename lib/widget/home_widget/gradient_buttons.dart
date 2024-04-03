import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final VoidCallback onSecondaryPressed;
  final List<Color> gradientColors;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.onSecondaryPressed,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 8), // Dışarıdan padding
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0), // Sol üst köşe sabit
            topRight: Radius.circular(20), // Sağ üst köşe yuvarlak
            bottomLeft: Radius.circular(30), // Sol alt köşe yuvarlak
            bottomRight: Radius.circular(30), // Sağ alt köşe yuvarlak
          ),
        ),
        elevation: 8, // Daha belirgin gölge
        child: Container(
          width: width,
          height: 160, // Yükseklik arttırıldı
          padding: EdgeInsets.only(top: 16, bottom: 16), // İç padding
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // İçeriği dikey olarak ayarla
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20, // Metin boyutunu arttır
                ),
              ),
              ElevatedButton(
                onPressed: onSecondaryPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary, // Buton arka plan rengi
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18), // Buton köşe yuvarlaklığı
                  ),
                  // Padding yok, çünkü boyutları aşağıda belirliyoruz
                ),
                child: Container(
                  width: 210, // Butonu konteynırın genişliğine göre genişlet
                  height: 20, // Butonun yüksekliği
                  alignment: Alignment.center,
                  child: Text(
                    'Başla',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
