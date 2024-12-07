import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_calendar/calendar_page/service/schedule_service.dart';
import 'package:kumoh_calendar/data/schedule_data.dart';

class EditSchedulePage extends StatefulWidget {
  const EditSchedulePage({super.key, required this.schedule});

  // schedule이 null이면 새로운 일정 추가, 아니면 일정 수정
  final ScheduleData? schedule;

  @override
  State<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  User? user = FirebaseAuth.instance.currentUser;
  ScheduleService service = ScheduleService();

  ScheduleData? schedule;

  late TextEditingController _titleController,
      _placeController,
      _memoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.schedule != null) {
        print(widget.schedule!.toJson().toString());
      } else {
        print("Add Schedule");
      }
      setState(() {
        schedule = widget.schedule != null
            ? widget.schedule!
            : ScheduleData(
                id: Random().nextInt(100000) + 1,
                name: '',
                userId: user!.uid,
                startDate: DateTime.now(),
                endDate: DateTime.now(),
                place: '',
                memo: '',
                participants: [],
              );

        _titleController = TextEditingController(text: schedule!.name);
        _placeController = TextEditingController(text: schedule!.place);
        _memoController = TextEditingController(text: schedule!.memo);
      });
    });
  }

  void onSubmit() {
    if (widget.schedule != null && schedule != null) {
      service.editSchedule(schedule!);
    } else {
      service.addSchedule(schedule!);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeButtonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
      ),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      )),
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leadingWidth: 64,
        actions: [
          TextButton(
            onPressed: onSubmit,
            child: const Icon(Icons.save),
          ),
        ],
      ),
      body: schedule != null
          ? Padding(
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
                            schedule!.name = value;
                          });
                        },
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '일정 이름',
                        ),
                        controller: _titleController),
                  ),
                  const SizedBox(height: 8),

                  // 날짜 섹션
                  ListTile(
                    titleAlignment: ListTileTitleAlignment.top,
                    leading: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Icon(Icons.calendar_today)),
                    title: Column(
                      // 날짜 선택
                      children: [
                        Row(
                          children: [
                            TextButton(
                              style: dateTimeButtonStyle,
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: schedule!.startDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null &&
                                    picked != schedule!.startDate) {
                                  setState(() {
                                    schedule!.startDate = picked;
                                    // endDate가 startDate보다 이전이면 같은 날짜로 설정
                                    if (schedule!.endDate
                                        .isBefore(schedule!.startDate)) {
                                      schedule!.endDate = picked;
                                    }
                                  });
                                }
                              },
                              child: Text(
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                                '${schedule!.startDate.year}년 ${schedule!.startDate.month}월 ${schedule!.startDate.day}일',
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            TextButton(
                              style: dateTimeButtonStyle,
                              onPressed: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      schedule!.startDate),
                                );
                                if (picked != null) {
                                  setState(() {
                                    schedule!.startDate = DateTime(
                                      schedule!.startDate.year,
                                      schedule!.startDate.month,
                                      schedule!.startDate.day,
                                      picked.hour,
                                      picked.minute,
                                    );
                                  });
                                }
                              },
                              child: Text(
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                                '${schedule!.startDate.hour}:${schedule!.startDate.minute}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            TextButton(
                              style: dateTimeButtonStyle,
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: schedule!.endDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null &&
                                    picked != schedule!.endDate) {
                                  setState(() {
                                    schedule!.endDate = picked;
                                    // startDate가 endDate보다 이후면 같은 날짜로 설정
                                    if (schedule!.startDate
                                        .isAfter(schedule!.endDate)) {
                                      schedule!.startDate = picked;
                                    }
                                  });
                                }
                              },
                              child: Text(
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                                '${schedule!.endDate.year}년 ${schedule!.endDate.month}월 ${schedule!.endDate.day}일',
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            TextButton(
                              style: dateTimeButtonStyle,
                              onPressed: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      TimeOfDay.fromDateTime(schedule!.endDate),
                                );
                                if (picked != null) {
                                  setState(() {
                                    schedule!.endDate = DateTime(
                                      schedule!.endDate.year,
                                      schedule!.endDate.month,
                                      schedule!.endDate.day,
                                      picked.hour,
                                      picked.minute,
                                    );
                                  });
                                }
                              },
                              child: Text(
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                                '${schedule!.endDate.hour}:${schedule!.endDate.minute}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // 장소 정보
                  ListTile(
                      leading: const Icon(Icons.location_on),
                      title: TextField(
                        onChanged: (value) {
                          setState(() {
                            schedule!.place = value;
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '장소 입력',
                        ),
                        controller: _placeController,
                      )),

                  // 메모 섹션
                  ListTile(
                    leading: const Icon(Icons.notes),
                    title: TextField(
                      onChanged: (value) {
                        setState(() {
                          schedule!.memo = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '메모 입력',
                      ),
                      controller: _memoController,
                    ),
                  ),

                  // TODO: 참가자 섹션
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: Text('참가자: ${schedule!.participants.join(", ")}'),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
