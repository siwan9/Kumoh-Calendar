import 'package:kumoh_calendar/menu/entity/Menu.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MenuRepository {
  final FirebaseFirestore _firestore;

  MenuRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 특정 날짜의 메뉴를 불러오는 메서드
  Future<List<Menu>> findByDate(final String date) async {
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
