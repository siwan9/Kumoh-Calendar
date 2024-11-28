import 'package:flutter/material.dart';

import 'schedule_item.dart';

class DateItemWidget extends StatefulWidget {
  const DateItemWidget(
      {super.key, required this.date, this.isCurrentMonth = true});

  final DateTime date;
  final bool isCurrentMonth;

  @override
  State<DateItemWidget> createState() => _DateItemState();
}

class _DateItemState extends State<DateItemWidget> {
  late bool isToday;

  @override
  void initState() {
    super.initState();
    isToday = DateTime.now().day == widget.date.day &&
        DateTime.now().month == widget.date.month &&
        DateTime.now().year == widget.date.year;
  }

  @override
  Widget build(BuildContext context) {
    var alpha = widget.isCurrentMonth ? 255 : 128;

    var schedules = <Widget>[
      const ScheduleItemWidget(name: '일정 1'),
      const SizedBox(height: 2),
      const ScheduleItemWidget(name: '일정 2'),
    ];

    return Container(
      padding: const EdgeInsets.all(2),
      // border
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(255, 217, 217, 217), width: .5),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: isToday ? BoxShape.circle : BoxShape.rectangle,
              color: isToday ? Color.fromARGB(alpha, 0, 128, 255) : null,
            ),
            child: Text(
                style: TextStyle(
                    color: isToday
                        ? Color.fromARGB(alpha, 255, 255, 255)
                        : (
                          widget.date.weekday == 7 ?
                          Color.fromARGB(alpha, 200, 0, 0) :
                          widget.date.weekday == 6 ?
                          Color.fromARGB(alpha, 0, 0, 200) :
                          Color.fromARGB(alpha, 0, 0, 0))
                        ),
                widget.date.day.toString()),
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: schedules,
          )
        ],
      ),
    );
  }
}
