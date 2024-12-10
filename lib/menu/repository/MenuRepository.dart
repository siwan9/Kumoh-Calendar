import 'package:kumoh_calendar/common/cache/CacheManager.dart';
import 'package:kumoh_calendar/menu/entity/Menu.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MenuRepository extends CacheManager<List<Menu>, String> {
  // 싱글톤 인스턴스
  static final MenuRepository _instance = MenuRepository._internal();

  // FirebaseFirestore 인스턴스
  FirebaseFirestore _firestore;

  // private named constructor
  MenuRepository._internal({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // factory constructor
  factory MenuRepository({FirebaseFirestore? firestore}) {
    // firestore 매개변수를 지원하기 위해 _firestore를 초기화
    if (firestore != null) {
      _instance._firestore = firestore;
    }
    return _instance;
  }

  Future<List<Menu>> findByDate(String date) async {
    return await get(date);
  }

  @override
  Future<List<Menu>> load(String date) async {
    try {
      // "menus" 컬렉션에서 date 필드가 일치하는 문서들 가져오기
      final querySnapshot = await _firestore
          .collection('menus')
          .where('date', isEqualTo: date)
          .get();

      // 문서들을 Menu 객체 리스트로 변환
      return querySnapshot.docs
          .map((doc) =>
              Menu.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching menus for date $date: $e');
      return [];
    }
  }
}
