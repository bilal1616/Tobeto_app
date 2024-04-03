import 'package:flutter/material.dart';
import 'package:tobeto_app/model/certificate.dart';
import 'package:tobeto_app/model/education.dart';
import 'package:tobeto_app/model/language.dart';
import 'package:tobeto_app/model/profile_settings.dart';
import 'package:tobeto_app/model/settings.dart';
import 'package:tobeto_app/model/skills.dart';
import 'package:tobeto_app/model/social_media.dart';
import 'package:tobeto_app/model/work.dart';

class ProfileInformation extends StatefulWidget {
  @override
  _ProfileInformationState createState() => _ProfileInformationState();
}

class _ProfileInformationState extends State<ProfileInformation> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 8,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.person),
              ),
              Tab(
                icon: Icon(Icons.work_outline),
              ),
              Tab(
                icon: Icon(Icons.view_agenda),
              ),
              Tab(
                icon: Icon(Icons.stars),
              ),
              Tab(
                icon: Icon(Icons.school),
              ),
              Tab(
                icon: Icon(Icons.share),
              ),
              Tab(
                icon: Icon(Icons.language),
              ),
              Tab(
                icon: Icon(Icons.settings),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ProfilTab(),
            WorkTab(),
            EductionTab(),
            SkillsTab(),
            CertificateTab(),
            SocialMediaTab(),
            LanguageTab(),
            SettingsTab(),
          ],
        ),
      ),
    );
  }
}
