import 'package:flutter/material.dart';

class TitleField extends StatelessWidget {
  final TextEditingController controller;

  const TitleField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: '회의 제목',
        border: InputBorder.none,
      ),
    );
  }
}