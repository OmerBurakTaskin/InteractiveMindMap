import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final double padding;
  final bool obscureText;
  CustomTextField(this.padding, this.labelText, this.obscureText, {super.key});
  final TextEditingController _textEditingController = TextEditingController();

  String getText() {
    return _textEditingController.text;
  }

  TextEditingController getController() {
    return _textEditingController;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(padding),
        child: TextField(
          controller: _textEditingController,
          obscureText: obscureText,
          decoration: InputDecoration(
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
              border: const UnderlineInputBorder(),
              labelText: labelText,
              labelStyle: const TextStyle(color: Colors.blue)),
          style: const TextStyle(color: Colors.black),
        ));
  }
}
