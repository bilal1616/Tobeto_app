import 'package:flutter/material.dart';

class SocialMedia {
  final String name;

  SocialMedia({required this.name});
}

class CustomSocialMediaDropdown extends StatelessWidget {
  final String labelText;
  final SocialMedia? selectedSocialMedia;
  final List<SocialMedia> options;
  final Function(SocialMedia?) onChanged;

  CustomSocialMediaDropdown({
    required this.labelText,
    required this.selectedSocialMedia,
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
            child: DropdownButtonFormField<SocialMedia>(
              value: selectedSocialMedia,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              items: options.map((SocialMedia media) {
                return DropdownMenuItem<SocialMedia>(
                  value: media,
                  child: Text(
                    media.name,
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

List<SocialMedia> socialMediaOptions = [
  SocialMedia(name: 'Twitter'),
  SocialMedia(name: 'LinkedIn'),
  SocialMedia(name: 'Instagram'),
  SocialMedia(name: 'Github'),
  SocialMedia(name: 'Medium'),
  SocialMedia(name: 'Facebook'),
];
