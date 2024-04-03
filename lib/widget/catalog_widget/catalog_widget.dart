import 'package:flutter/material.dart';
import 'package:tobeto_app/widget/catalog_widget/catalog_data.dart';
import 'package:tobeto_app/widget/catalog_widget/video_player_screen.dart';

class CatalogWidget extends StatelessWidget {
  const CatalogWidget({Key? key, required this.catalogModel}) : super(key: key);
  final CatalogModel catalogModel;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    // Ekran genişliği
    double screenWidth = mediaQuery.size.width;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideoApp(
              videoURL: catalogModel.videoURL,
              title: catalogModel.title,
              subtitle: catalogModel.name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(10.0), // Kartın köşelerini ovalleştir
          color: Colors.white, // Kart arka plan rengi
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Kart gölgesi rengi
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3), // Kart gölgesi ofseti
            ),
          ],
        ),
        child: Stack(
          children: [
            // Arka plan resmi
            Image.network(
              catalogModel.imagePath,
              fit: BoxFit.cover, // Resmi tamamen kapla
            ),

            // Metin ve düğmeler
            Positioned(
              bottom: 0.0,
              left: 0.0,
              child: Container(
                width: screenWidth,
                padding: EdgeInsets.all(8.0),
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          catalogModel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.access_time,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          catalogModel.time,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      catalogModel.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 20.0,
              right: 20.0,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoApp(
                        videoURL: catalogModel.videoURL,
                        title: catalogModel.title,
                        subtitle: catalogModel.name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle),
                iconSize: 50,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
