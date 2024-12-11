import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_calendar/data/schedule_data.dart';

import '../edit_schedule_page/page.dart';
import '../service/schedule_service.dart';

class ViewSchedulePage extends StatefulWidget {
  const ViewSchedulePage({super.key, required this.schedule});

  final ScheduleData schedule;

  @override
  State<ViewSchedulePage> createState() => _ViewSchedulePageState();
}

class _ViewSchedulePageState extends State<ViewSchedulePage> {
  User? user = FirebaseAuth.instance.currentUser;
  final service = ScheduleService();

  late ScheduleData schedule;

  @override
  void initState() {
    super.initState();
    schedule = widget.schedule;
    service.onScheduleChanged.listen((event) {
      _refresh();
    });
  }

  void _refresh() {
    service.getScheduleById(schedule.id).then((value) {
      setState(() {
        schedule = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // set padding to 4px
        toolbarHeight: 64,
        leadingWidth: 64,
        actions: [
          ...(schedule.editable
              ? [
                  // delete button
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // delete schedule
                      service.deleteSchedule(schedule.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('일정이 삭제되었습니다.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // edit schedule
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return EditSchedulePage(schedule: schedule);
                          },
                        ),
                      );
                    },
                  )
                ]
              : []),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 일정 이름
            ListTile(
              leading: const SizedBox(
                width: 24,
                height: 24,
              ),
              title: Text(
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                schedule.name,
              ),
            ),
            const SizedBox(height: 8),

            // 날짜 섹션
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                schedule.startDate == schedule.endDate
                    ? "${schedule.startDate.year}/${schedule.startDate.month}/${schedule.startDate.day} ${schedule.startDate.hour}:${schedule.startDate.minute}"
                    : "${schedule.startDate.year}/${schedule.startDate.month}/${schedule.startDate.day} ${schedule.startDate.hour}:${schedule.startDate.minute} ~ ${schedule.endDate.year}/${schedule.endDate.month}/${schedule.endDate.day} ${schedule.endDate.hour}:${schedule.endDate.minute}",
              ),
            ),
            const Divider(),

            // 장소 정보
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(schedule.place),
            ),

            // 메모 섹션
            ListTile(
              leading: const Icon(Icons.notes),
              title: Text(schedule.memo),
            ),

            // 참가자 섹션
            ListTile(
              leading: const Icon(Icons.people),
              title: Text('참가자: ${schedule.participants.join(", ")}'),
            ),
          ],
        ),
      ),
    );
  }
}
