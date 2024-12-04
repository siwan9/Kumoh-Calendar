import 'package:flutter/material.dart';

class DateTimeRow extends StatelessWidget {
  final String title;
  final DateTime dateTime;
  final IconData icon;
  final bool isStartDate;
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
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 (${_getDayOfWeek(dateTime.weekday)})',
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
          TimeOfDay? pickedTime = await _showCustomTimePicker(context, TimeOfDay.fromDateTime(dateTime));

          if (pickedTime != null) {
            onDateTimeChanged(DateTime(
              pickedDateTime.year,
              pickedDateTime.month,
              pickedDateTime.day,
              pickedTime.hour,
              pickedTime.minute,
            ));
          }
        }
      },
    );
  }

  Future<TimeOfDay?> _showCustomTimePicker(BuildContext context, TimeOfDay initialTime) async {
    int selectedHour = initialTime.hour;

    return showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('시간 선택'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(24, (index) {
                return ListTile(
                  title: Text('${index}시'),
                  onTap: () {
                    Navigator.of(context).pop(TimeOfDay(hour: index, minute: 0));
                  },
                  selected: index == selectedHour,
                );
              }),
            ),
          ),
        );
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
    String minute = dateTime.minute < 10 ? '0${dateTime.minute}' : '${dateTime.minute}';
    return '$period $hour:$minute';
  }
}
