import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tobeto_app/widget/catalog_widget/catalog_data.dart';
import 'package:tobeto_app/widget/catalog_widget/catalog_widget.dart';
import 'package:tobeto_app/widget/catalog_widget/catalog_pagination.dart';

class Catalog extends StatefulWidget {
  final bool showAppBar;
  const Catalog({Key? key, this.showAppBar = false}) : super(key: key);

  @override
  _CatalogState createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _catalogStream;
  String _searchText = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _catalogStream =
        FirebaseFirestore.instance.collection('catalog-card').snapshots();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.trim(); // Arama sorgusunu düzelt
    });
  }

  void _handlePageChange(int page) {
    setState(() {
      _currentPage = page;
    });
    _onSearchChanged(); // Sayfa değiştiğinde tekrar arama yap
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    String imagePath =
        isDarkMode ? "assets/tobeto-logo-dark.png" : "assets/tobeto-logo.png";

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Image.asset(imagePath, width: 120, height: 60),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 275,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/banner.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Eğitim arayın...",
                      hintStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      prefixIcon: Icon(Icons.search),
                      fillColor: Color.fromARGB(221, 234, 234, 234),
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14), // İçerik dolgusunu azalt
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            StreamBuilder<QuerySnapshot>(
              stream: _catalogStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs
                    .where((doc) => doc['instructor']
                        .toLowerCase()
                        .contains(_searchText.toLowerCase()))
                    .toList();

                final totalCards = docs.length;
                final totalPages = (totalCards / 3).ceil();

                final start = (_currentPage - 1) * 3;
                final end = min(_currentPage * 3, totalCards);
                final pageDocs =
                    start < totalCards ? docs.sublist(start, end) : [];

                return Column(
                  children: [
                    if (pageDocs.isEmpty &&
                        totalCards == 0) // Eğer hiç kart yoksa
                      Text(
                        'Eğitim bulunamadı.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    for (var doc in pageDocs)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CatalogWidget(
                          catalogModel: CatalogModel(
                            id: doc.id,
                            imagePath: doc['imageUrl'],
                            name: doc['instructor'],
                            time: doc['time'],
                            title: doc['title'],
                            videoURL: doc['videoURL'],
                          ),
                        ),
                      ),
                    if (totalPages > 1) // Birden fazla sayfa varsa
                      PaginationWidget(
                        currentPage: _currentPage,
                        totalPages: totalPages,
                        onPageChanged: _handlePageChange,
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          ],
        ),
      ),
    );
  }
}
