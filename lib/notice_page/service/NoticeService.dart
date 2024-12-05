import 'package:kumoh_calendar/notice_page/entity/GeneralNotice.dart';
import 'package:kumoh_calendar/notice_page/entity/Notice.dart';
import 'package:kumoh_calendar/notice_page/repository/NoticeRepository.dart';

class NoticeService {
  final NoticeRepository _repository = NoticeRepository();

  Future<List<Notice>> getNotices(String noticeType) async {
    return await _repository.fetchNotices(noticeType);
  }

  Future<List<GeneralNotice>> getGeneralNotices(
      String noticeType, int limit) async {
    return await _repository.fetchGeneralNotices(noticeType, limit);
  }
}
