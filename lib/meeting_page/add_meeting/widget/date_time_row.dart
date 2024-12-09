import 'package:flutter/material.dart';

class DateTimeRow extends StatelessWidget {
  final String title;
  final DateTime dateTime;
  final IconData icon;
  final bool isStartDate; // 시작/종료 날짜 구분 변수
  final ValueChanged<DateTime> onDateTimeChanged;

  const DateTimeRow({
    Key? key,
    required this.title,
    required this.dateTime,
    required this.icon,
    required this.isStartDate,
    required this.onDateTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 (${_getDayOfWeek(dateTime.weekday)})',
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: dateTime,
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          onDateTimeChanged(pickedDate);
        }
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
}
