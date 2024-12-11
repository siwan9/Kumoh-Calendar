import 'package:flutter/material.dart';
import 'package:kumoh_calendar/notice_page/entity/GeneralNotice.dart';
import 'package:kumoh_calendar/notice_page/entity/Notice.dart';
import 'package:kumoh_calendar/notice_page/service/NoticeService.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key, required this.setTitle, required this.setMenu});

  final Function(Widget) setTitle;
  final Function(List<Widget>) setMenu;

  @override
  State<NoticePage> createState() => _NoticePageState();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setTitle(const Text('공지사항'));
      widget.setMenu([]);
    });
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
      backgroundColor: Colors.white,
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
    return ElevatedButton(
      onPressed: () async {
        if (selectedType != type) {
          setState(() {
            selectedType = type;
            notices.clear();
            generalNotices.clear();
            generalNoticePage = 0;
          });
          await fetchNotices(); // Notice 데이터 다시 로딩
          await fetchGeneralNotices(); // GeneralNotice 데이터 다시 로딩
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedType == type ? Colors.blue : Colors.grey[300], // 배경색
        foregroundColor:
            selectedType == type ? Colors.white : Colors.black, // 텍스트 색상
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 여백
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)), // 텍스트 스타일
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
