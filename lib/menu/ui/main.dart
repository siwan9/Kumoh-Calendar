import 'package:flutter/material.dart';
import 'RestaurantTab.dart'; // RestaurantTab UI 파일을 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 숨기기
      title: '식단 및 공지사항 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RestaurantTab(), // 앱이 실행될 때 표시될 초기 화면
    );
  }
}
