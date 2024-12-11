/*
### 학사일정

- 이름 (string)
- 시작 날짜/시간 (string)
- 종료 날짜/시간 (string)
*/

import 'dart:math';

import 'package:kumoh_calendar/data/schedule_data.dart';

class AcademicScheduleData {
  String name;
  DateTime startDate;
  DateTime endDate;

  AcademicScheduleData({
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  factory AcademicScheduleData.fromJson(Map<String, dynamic> json) {
    return AcademicScheduleData(
      name: json['title'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  ScheduleData toScheduleData() {
    return ScheduleData(
      editable: false,
      id: Random().nextInt(100000) + 1000000,
      name: name,
      userId: '',
      startDate: startDate,
      endDate: endDate,
      place: '',
      memo: '',
      participants: [],
    );
  }
}
