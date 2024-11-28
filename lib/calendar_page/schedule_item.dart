import 'package:flutter/material.dart';

class ScheduleItemWidget extends StatelessWidget {
  const ScheduleItemWidget({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue),
        alignment: Alignment.centerLeft,
        minimumSize: WidgetStateProperty.all(const Size(0, 24)),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 4)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        )),
      ),
      child: Text(style: const TextStyle(color: Colors.white), name),
    );
  }
}
