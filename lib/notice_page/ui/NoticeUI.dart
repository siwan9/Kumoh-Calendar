import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_calendar/firebase_options.dart';
import 'package:kumoh_calendar/notice_page/entity/GeneralNotice.dart';
import 'package:kumoh_calendar/notice_page/entity/Notice.dart';
import 'package:kumoh_calendar/notice_page/service/NoticeService.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final NoticeService _noticeService = NoticeService();

  String selectedType = "ACADEMIC"; // 기본 선택
  List<Notice> notices = [];
  List<GeneralNotice> generalNotices = [];
  int generalNoticePage = 0;

  @override
  void initState() {
    super.initState();
    fetchNotices();
    fetchGeneralNotices();
  }

  // Notices 데이터를 불러오는 메서드
  Future<void> fetchNotices() async {
    final fetchedNotices = await _noticeService.getNotices(selectedType);
    setState(() {
      notices = fetchedNotices;
    });
  }

  // General Notices 데이터를 불러오는 메서드
  Future<void> fetchGeneralNotices() async {
    final fetchedGeneralNotices =
        await _noticeService.getGeneralNotices(selectedType, 14);
    setState(() {
      generalNotices = fetchedGeneralNotices;
      generalNoticePage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("공지사항"),
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTypeSelector(),
          Expanded(
            child: ListView.builder(
              itemCount: notices.length + generalNotices.length + 2,
              itemBuilder: (context, index) {
                return _buildListItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTypeButton("ACADEMIC", "학사안내"),
        _buildTypeButton("EVENT", "행사안내"),
        _buildTypeButton("NORMAL", "일반소식"),
      ],
    );
  }

  Widget _buildTypeButton(String type, String label) {
    bool isSelected = selectedType == type;
    return ElevatedButton(
      onPressed: isSelected
          ? null
          : () async {
              setState(() {
                selectedType = type;
                notices.clear();
                generalNotices.clear();
                generalNoticePage = 0;
              });
              await fetchNotices(); // Notice 데이터 다시 로딩
              await fetchGeneralNotices(); // GeneralNotice 데이터 다시 로딩
            },
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.blue : Colors.grey[300],
      ),
      child: Text(label),
    );
  }

  Widget _buildListItem(int index) {
    // 공지사항 섹션 헤더 처리
    if (index == 0) {
      return _buildSectionHeader("공지사항");
    }

    // 공지사항 데이터 처리
    if (index > 0 && index <= notices.length) {
      return _buildNoticeTile(notices[index - 1]);
    }

    // 일반 소식 섹션 헤더 처리
    if (index == notices.length + 1 && generalNotices.isNotEmpty) {
      return _buildSectionHeader("일반 소식");
    }

    // 일반 소식 데이터 처리
    int generalIndex = index - notices.length - 2; // 일반 소식의 실제 인덱스 계산
    if (generalNotices.isNotEmpty &&
        generalIndex >= 0 &&
        generalIndex < generalNotices.length) {
      return _buildGeneralNoticeTile(generalNotices[generalIndex]);
    }

    // 유효하지 않은 경우 빈 공간 반환
    return const SizedBox.shrink();
  }

  Widget _buildNoticeTile(Notice notice) {
    return ListTile(
      title: Text(notice.title),
      subtitle: Text(notice.date),
      onTap: () => _launchUrl(notice.url),
    );
  }

  Widget _buildGeneralNoticeTile(GeneralNotice notice) {
    return ListTile(
      title: Text(notice.title),
      subtitle: Text(notice.date),
      onTap: () => _launchUrl(notice.url),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
