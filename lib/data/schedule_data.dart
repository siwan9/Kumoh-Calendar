/*
### 일정

- id(number)
- 이름 (string)
- 유저 id (number)
- 시작 날짜/시간 (timestamp)
- 종료 날짜/시간 (timestamp, optional)
- 장소 (string)
- 메모 (string)
- 참여 유저 id (number list)
*/

class ScheduleData {
  final int id;
  final String name;
  final int userId;
  final DateTime startDate;
  final DateTime endDate;
  final String place;
  final String memo;
  final List<int> participants;

  ScheduleData({
    required this.id,
    required this.name,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.place,
    required this.memo,
    required this.participants,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    return ScheduleData(
      id: json['id'],
      name: json['name'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      place: json['place'],
      memo: json['memo'],
      participants: List<int>.from(json['participants']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'place': place,
      'memo': memo,
      'participants': participants,
    };
  }
}