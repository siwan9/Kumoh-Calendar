import 'package:kumoh_calendar/calendar_page/repository/schedule_repository.dart';
import 'package:kumoh_calendar/data/schedule_data.dart';

class ScheduleService {
  final ScheduleRepository _repository = ScheduleRepository();

  void setUserId(String userId) {
    _repository.setUserId(userId);
  }

  Future<List<ScheduleData>> getSchedules() async {
    var schedules = await _repository.fetchSchedules();
    var academicSchedules = await _repository.fetchAcademicSchedules();
    return [...academicSchedules, ...schedules];
  }

  //get schedule by id
  Future<ScheduleData> getScheduleById(int id) async {
    return await _repository.fetchScheduleById(id);
  }

  Future<void> addSchedule(ScheduleData schedule) async {
    await _repository.addSchedule(schedule);
  }

  Future<void> editSchedule(ScheduleData schedule) async {
    await _repository.editSchedule(schedule);
  }

  Future<void> deleteSchedule(int id) async {
    await _repository.deleteSchedule(id);
  }

  Stream<ScheduleData> get onScheduleChanged => _repository.onScheduleChanged;
}
