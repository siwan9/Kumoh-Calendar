import 'package:flutter/material.dart';
import 'package:kumoh_calendar/meeting_page/add_metting_page.dart';
import 'package:kumoh_calendar/meeting_page/meeting_availabilit_page.dart';

class MeetingSchedulePage extends StatelessWidget {
  const MeetingSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약속 잡기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('오늘'),
            _buildMeetingCard(context),
            _buildSectionTitle('내일'),
            _buildMeetingCard(context),
            _buildMeetingCard(context),
            _buildSectionTitle('이번 주'),
            _buildMeetingCard(context),
            _buildMeetingCard(context),
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
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context) {
    return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MeetingAvailabilityPage()),
      );
    },
    child: const Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('회의 이름', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('장소: 디지털관 지하'),
            Text('인원: 5명'),
            SizedBox(height: 8),
            Text('내일 19:30~20:30', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    ),
  );
  }
}
