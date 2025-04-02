import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  const CustomTextfield({
    super.key,
    required this.hintText,
    this.obsecuretext = false,
    required this.controller,
  });

  final String hintText;
  final bool obsecuretext;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        obscureText: obsecuretext,
        controller: controller,

        decoration: InputDecoration(hintText: hintText),
        validator: (value) {
          if (value == null && value!.trim().isEmpty) {
            return '$hintText is missing';
          }
          return null;
        },
      ),
    );
  }
}
