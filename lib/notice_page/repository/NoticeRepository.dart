import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kumoh_calendar/common/cache/CacheManager.dart';
import 'package:kumoh_calendar/notice_page/entity/GeneralNotice.dart';
import 'package:kumoh_calendar/notice_page/entity/Notice.dart';

class NoticeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 싱글톤 인스턴스
  static final NoticeRepository _instance = NoticeRepository._internal();

  // private named constructor
  NoticeRepository._internal();

  // factory constructor
  factory NoticeRepository() {
    return _instance;
  }

  // 공지사항으로 되어 있는 학교 공지 목록 가져오기
  Future<List<Notice>> fetchNotices(String noticeType) async {
    final querySnapshot = await _firestore
        .collection('notices')
        .where('noticeType', isEqualTo: noticeType)
        .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Notice.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // 일반 공지사항으로 되어 있는 학교 공지 목록 가져오기
  Future<List<GeneralNotice>> fetchGeneralNotices(
      String noticeType, int limit) async {
    final querySnapshot = await _firestore
        .collection('generalNotices')
        .where('noticeType', isEqualTo: noticeType)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map(
            (doc) => GeneralNotice.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
