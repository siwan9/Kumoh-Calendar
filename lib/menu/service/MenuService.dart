// ignore: file_names
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_calendar/firebase_options.dart';
import 'package:kumoh_calendar/menu/entity/Menu.dart';
import 'package:kumoh_calendar/menu/repository/MenuRepository.dart';

class MenuService {
  final MenuRepository repository = MenuRepository();

  Future<List<Menu>> getMenus(String date) async {
    return await repository.findByDate(date);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // void에 Future 추가
  MenuService menuService = MenuService();
  String testDate = '2024-11-30';

  try {
    List<Menu> menus = await menuService.getMenus(testDate); // await 꼭 필요
    print('Menus on $testDate:');
    menus.forEach((menu) => print(menu.toJson()));
  } catch (e) {
    print('Error: $e');
  }
}
