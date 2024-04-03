import 'package:flutter/material.dart';

class Skill {
  final String name;

  Skill({required this.name});
}

class CustomSkillsDropdown extends StatelessWidget {
  final String labelText;
  final Skill? selectedSkill;
  final List<Skill> options;
  final Function(Skill?) onChanged;

  CustomSkillsDropdown({
    required this.labelText,
    required this.selectedSkill,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            textAlign: TextAlign.left,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 57.0,
            child: DropdownButtonFormField<Skill>(
              value: selectedSkill,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              items: options.map((Skill skill) {
                return DropdownMenuItem<Skill>(
                  value: skill,
                  child: Text(
                    skill.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

List<Skill> skills = [
  Skill(name: 'C#'),
  Skill(name: 'SQL'),
  Skill(name: 'Muhasebe'),
  Skill(name: 'Javascript'),
  Skill(name: 'Aktif Öğrenme'),
  Skill(name: 'Aktif Dinleme'),
  Skill(name: 'Uyum Sağlama'),
  Skill(name: 'Yönetim ve İdare'),
  Skill(name: 'Reklam'),
  Skill(name: 'Algoritmalar'),
  Skill(name: 'Android'),
];
