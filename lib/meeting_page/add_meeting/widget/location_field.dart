import 'package:flutter/material.dart';

class LocationField extends StatelessWidget {
  final TextEditingController controller;

  const LocationField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: '회의 장소',
          border: InputBorder.none,
        ),
      ),
    );
  }
}
