import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompCustomTextField extends StatelessWidget {
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final String? helperText;
  final IconData? iconData;
  final TextEditingController? controller;
  final bool obscureText;

  CompCustomTextField({
    Key? key,
    this.inputFormatters,
    this.hintText,
    this.helperText,
    this.iconData,
    this.controller,
    required this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (helperText != null)
            Text(
              helperText!,
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
            height: 45.0,
            child: TextField(
              obscureText: obscureText,
              controller: controller,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                prefixIcon: iconData != null
                    ? Icon(iconData, color: Colors.grey)
                    : null,
                helperText: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
