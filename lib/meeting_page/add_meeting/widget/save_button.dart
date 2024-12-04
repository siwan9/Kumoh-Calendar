import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // 둥근 모양
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15.0), // 가로 여백
          backgroundColor: Colors.black, // 배경색
          foregroundColor: Colors.white, // 텍스트 색상
          elevation: 0,
        ),
        child: const Text('저장'),
      ),
    );
  }
}
