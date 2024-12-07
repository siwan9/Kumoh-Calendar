import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_calendar/calendar_page/service/schedule_service.dart';
import 'package:kumoh_calendar/data/schedule_data.dart';

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  User? user = FirebaseAuth.instance.currentUser;
  ScheduleService service = ScheduleService();

  late ScheduleData schedule;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        schedule = ScheduleData(
          id: Random().nextInt(100000) + 1,
          name: '',
          userId: user!.uid,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          place: '',
          memo: '',
          participants: [],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leadingWidth: 64,
        actions: [
          TextButton(
            onPressed: () {
              service.addSchedule(schedule);
              Navigator.pop(context);
            },
            child: const Icon(Icons.save),
          ),
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
              title: TextField(
                onChanged: (value) {
                  setState(() {
                    schedule.name = value;
                  });
                },
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '일정 이름',
                ),
              ),
            ),
            const SizedBox(height: 8),

            // TODO: 날짜 섹션
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
                title: TextField(
                  onChanged: (value) {
                    setState(() {
                      schedule.place = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '장소 입력',
                  ),
                )),

            // 메모 섹션
            ListTile(
              leading: const Icon(Icons.notes),
              title: TextField(
                onChanged: (value) {
                  setState(() {
                    schedule.memo = value;
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '메모 입력',
                ),
              ),
            ),

            // TODO: 참가자 섹션
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
