import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:kumoh_calendar/meeting_page/add_meeting/page/add_metting_page.dart';
import 'package:kumoh_calendar/meeting_page/meeting_availability/page/meeting_availability_page.dart';

class MeetingSchedulePage extends StatefulWidget {
  const MeetingSchedulePage(
      {super.key, required this.setTitle, required this.setMenu});

  final Function(Widget) setTitle;
  final Function(List<Widget>) setMenu;

  @override
  State<MeetingSchedulePage> createState() => _MeetingSchedulePageState();
}

class _MeetingSchedulePageState extends State<MeetingSchedulePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _meetingData = []; // 타입 변경

  @override
  void initState() {
    super.initState();
    _fetchMeetings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setTitle(const Text('그룹일정'));
      widget.setMenu([]);
    });
  }

  Future<void> _fetchMeetings() async {
    String? userId = _auth.currentUser?.uid;

    if (userId == null) return;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('meeting_groups')
        .orderBy('created_at', descending: true) // 최신순으로 정렬
        .get();

    List<Map<String, dynamic>> userMeetings = []; // 로그인된 유저가 참여한 미팅 리스트

    for (var doc in querySnapshot.docs) {
      // Null 체크 및 타입 변환
      var data = doc.data() as Map<String, dynamic>?; // 명시적으로 Map<String, dynamic>으로 변환

      if (data != null) {
        var memberList = data['member_list'] ; // member_list를 안전하게 가져옵니다.

        // memberList가 null이 아닌 경우에만 처리
        if (memberList != null && memberList.containsKey(userId)) {
          // 미팅 데이터를 리스트에 추가합니다.
          userMeetings.add({
            'id': doc.id, // 문서의 고유 ID
            ...data, // 문서의 데이터
          });
        }
      }
    }

    setState(() {
      _meetingData = userMeetings; // 로그인된 유저가 참여한 미팅 리스트
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
        onPressed: () async{
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMeetingPage(meetingData: {})),
          );

          if (result == true) {
            _fetchMeetings();
          }
        },
        backgroundColor: Colors.blue, // 버튼 배경색
        shape: const CircleBorder(),
        child: const Icon(
          color: Colors.white,
          Icons.add,
        ),
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
    return _meetingData.map((meeting) {
      return GestureDetector(
        onTap: () async{
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MeetingAvailabilityPage(
              meetingData: meeting)) // 회의 ID 전달
          );

          if (result == true) {
            _fetchMeetings();
          }
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meeting['name'] ?? '회의 이름',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('장소: ${meeting['location'] ?? '장소 미정'}'),
                Text('인원: ${meeting['member_list'].length}명'),
                const SizedBox(height: 8),
                // 날짜 및 시간 형식은 필요한 대로 수정
                Text(
                  '${DateFormat('yyyy-MM-dd').format(meeting['start_date'].toDate())} ~ ${DateFormat('yyyy-MM-dd').format(meeting['finish_date'].toDate())}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
