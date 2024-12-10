import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_calendar/calendar_page/date_item.dart';
import 'package:kumoh_calendar/calendar_page/edit_schedule_page/page.dart';

import '../data/schedule_data.dart';
import 'service/schedule_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage(
      {super.key, required this.setTitle, required this.setMenu});

  final Function(Widget) setTitle;
  final Function(List<Widget>) setMenu;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final service = ScheduleService();

  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  List<ScheduleData> _schedules = [];

  DateTime get _firstDateOfMonth {
    return DateTime(_currentYear, _currentMonth, 1);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setTitle(Text("$_currentMonth월"));
      widget.setMenu([
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevMonth,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _nextMonth,
        ),
      ]);
      _refresh();
    });

    service.setUserId(user!.uid);

    service.onScheduleChanged.listen((event) {
      _refresh();
    });
  }

  void _refresh() {
    service.getSchedules().then((value) {
      setState(() {
        _schedules = value;
      });
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentYear++;
        _currentMonth = 1;
      } else {
        _currentMonth++;
      }
      widget.setTitle(Text("$_currentMonth월"));
    });
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentYear--;
        _currentMonth = 12;
      } else {
        _currentMonth--;
      }
      widget.setTitle(Text("$_currentMonth월"));
    });
  }

  @override
  Widget build(BuildContext context) {
    var datesOfMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    // 표시되여할 주 길이
    var weekLength = (datesOfMonth + _firstDateOfMonth.weekday - 1) ~/ 7 + 1;
    // date list of a week
    var month = List<List<Widget>>.generate(
        weekLength,
        (week) => List<Widget>.generate(7, (index) {
              var dateTime = _firstDateOfMonth
                  .subtract(Duration(days: _firstDateOfMonth.weekday))
                  .add(Duration(days: week * 7 + index));
              return Expanded(
                  child: DateItemWidget(
                key: ValueKey(dateTime),
                date: dateTime,
                isCurrentMonth: dateTime.month == _currentMonth,
                schedules: [
                  for (var schedule in _schedules)
                    if (schedule.startDate.day == dateTime.day &&
                        schedule.startDate.month == dateTime.month &&
                        schedule.startDate.year == dateTime.year)
                      schedule
                ],
              ));
            }));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        Row(
          children: const ['일', '월', '화', '수', '목', '금', '토']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ))
              .toList(),
        ),
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Expanded(
                  child: Column(
                children: month
                    .map((week) => Expanded(
                            child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: week,
                        )))
                    .toList(),
              ))
            ]))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditSchedulePage(schedule: null),
            ),
          );
        },
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(
          color: Colors.white,
          Icons.add,
        ),
      ),
    );
  }
}
