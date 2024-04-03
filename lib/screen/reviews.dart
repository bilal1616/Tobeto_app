import 'package:flutter/material.dart';
import 'package:tobeto_app/widget/reviews_widget/reviews_button.dart';
import 'package:tobeto_app/widget/reviews_widget/reviews_categories.dart';
import 'package:tobeto_app/widget/reviews_widget/reviews_descriptioncard.dart';
import 'package:tobeto_app/widget/reviews_widget/reviews_notbutton.dart';

class Reviews extends StatefulWidget {
  final bool showAppBar;
  const Reviews({Key? key, this.showAppBar = false}) : super(key: key);

  @override
  _ReviewsState createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    String imagePath =
        isDarkMode ? "assets/tobeto-logo-dark.png" : "assets/tobeto-logo.png";

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Image.asset(
                imagePath,
                width: 120,
                height: 60,
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.07),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Yetkin',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                    ),
                    TextSpan(
                      text: 'liklerini ücretsiz ölç,\n',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                    ),
                    TextSpan(
                      text: 'bilgi',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                    ),
                    TextSpan(
                      text: 'lerini test et.',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                    ),
                  ]),
                ),
              ),
              ReviewsButton(),
              ReviewsNotbutton(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              ...reviewCategories
                  .map((category) => Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              category['icon'],
                              color: category['color'],
                            ),
                          ),
                          title: Text(
                            category['title'],
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              showReviewCategoryDialog(
                                  context, category['title']);
                            },
                            child: Text(
                              category['buttonText'],
                              style: TextStyle(
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    Theme.of(context).colorScheme.background,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          ),
                          tileColor: category['color'],
                        ),
                      ))
                  .toList(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.09),
              _buildDecoratedImage(context),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.1),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Aboneliğe özel\n',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                    ),
                    TextSpan(
                      text: 'değerlendirme araçları için',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color),
                    ),
                  ]),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              const Reviewsdescriptioncard(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecoratedImage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1.0),
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Opacity(
        opacity: 0.8,
        child: Image.asset(
          "assets/images.png",
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}
