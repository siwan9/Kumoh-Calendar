import 'package:flutter/material.dart';
import 'package:kumoh_calendar/data/schedule_data.dart';

class ViewSchedulePage extends StatelessWidget {
  const ViewSchedulePage({super.key, required this.schedule});

  final ScheduleData schedule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // set padding to 4px
        toolbarHeight: 64,
        leadingWidth: 64,

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
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
