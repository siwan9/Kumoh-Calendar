import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kumoh_calendar/meeting_page/add_meeting/page/add_metting_page.dart';
import 'package:kumoh_calendar/meeting_page/meeting_availability/page/meeting_availability_page.dart';

class MeetingSchedulePage extends StatefulWidget {
  const MeetingSchedulePage({super.key});

  @override
  _MeetingSchedulePageState createState() => _MeetingSchedulePageState();
}

class _MeetingSchedulePageState extends State<MeetingSchedulePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> _meetings = [];

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    String? userId = _auth.currentUser?.uid;

    if (userId == null) return;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('meeting_groups')
        .where('member_list', arrayContains: userId) // 현재 사용자의 UID가 포함된 회의 검색
        .get();

    setState(() {
      _meetings = querySnapshot.docs; // 회의 목록 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('전체'),
            ..._buildMeetingCards(), // 회의 카드 출력
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMeetingPage()),
          );
        },
        backgroundColor: Colors.blue, // 버튼 배경색
        child: const Icon(Icons.add), // 버튼 아이콘
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> _buildMeetingCards() {
    return _meetings.map((meeting) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MeetingAvailabilityPage()),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meeting['name'] ?? '회의 이름', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('장소: ${meeting['location'] ?? '장소 미정'}'),
                Text('인원: ${meeting['member_list'].length}명'),
                const SizedBox(height: 8),
                // 날짜 및 시간 형식은 필요한 대로 수정
                Text('${meeting['start_date'].toDate()}~${meeting['finish_date'].toDate()}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
