import 'package:flutter/material.dart';

class AddMeetingPage extends StatefulWidget {
  const AddMeetingPage({super.key});

  @override
  _AddMeetingPageState createState() => _AddMeetingPageState();
}

class _AddMeetingPageState extends State<AddMeetingPage> {
  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now().add(const Duration(hours: 1));
  final String _location = '위치 추가';
  final String _user = '사용자 추가';
  final String _reminder = '30분 전';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('제목 추가'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                // 저장 로직 추가
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('저장되었습니다.')),
                );
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // 둥근 모양
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15.0), // 가로 여백
                backgroundColor: Colors.black, // 배경색 투명
                foregroundColor: Colors.white, // 텍스트 색상
                // 추가적으로 그림자 없애기
                elevation: 0,
              ),
              child: const Text('저장'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTitleField(),
            _buildDateTimeRow('시작 날짜', _startDateTime),
            _buildDateTimeRow('종료 날짜', _endDateTime),
            _buildLocationField(),
            _buildUserField(),
            _buildRecurringField(),
            _buildReminderField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return const TextField(
      decoration: InputDecoration(
        labelText: '회의 제목',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateTimeRow(String title, DateTime dateTime) {
    return ListTile(
      title: Text(title),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 (${_getDayOfWeek(dateTime.toLocal().weekday)})',
          ),
          Text(
            _formatTime(dateTime),
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () async {
        DateTime? pickedDateTime = await showDatePicker(
          context: context,
          initialDate: dateTime,
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (pickedDateTime != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(dateTime),
          );

          if (pickedTime != null) {
            setState(() {
              _startDateTime = DateTime(
                pickedDateTime.year,
                pickedDateTime.month,
                pickedDateTime.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }
        }
      },
    );
  }

  Widget _buildLocationField() {
    return ListTile(
      title: Text(_location),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // 위치 선택 로직 추가
      },
    );
  }

  Widget _buildUserField() {
    return ListTile(
      title: Text(_user),
      trailing: TextButton(
        onPressed: () {
          // 사용자 추가 로직 추가
        },
        child: const Text('일정 보기'),
      ),
    );
  }

  Widget _buildRecurringField() {
    return ListTile(
      title: const Text('화상 회의 추가'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // 화상 회의 추가 로직 추가
      },
    );
  }

  Widget _buildReminderField() {
    return ListTile(
      title: const Text('알림'),
      subtitle: Text(_reminder),
      trailing: const Icon(Icons.close),
      onTap: () {
        // 알림 설정 로직 추가
      },
    );
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return '월';
      case 2: return '화';
      case 3: return '수';
      case 4: return '목';
      case 5: return '금';
      case 6: return '토';
      case 7: return '일';
      default: return '';
    }
  }

  String _formatTime(DateTime dateTime) {
    String period = dateTime.hour >= 12 ? '오후' : '오전';
    int hour = dateTime.hour % 12;
    hour = hour == 0 ? 12 : hour; // 0시는 12시로 변환
    String minute = dateTime.minute < 10 ? '0${dateTime.minute}' : '${dateTime.minute}';
    return '$period $hour:$minute';
  }
}
