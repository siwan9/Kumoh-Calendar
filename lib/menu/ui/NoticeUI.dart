import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_calendar/firebase_options.dart';
import 'package:kumoh_calendar/menu/entity/GeneralNotice.dart';
import 'package:kumoh_calendar/menu/entity/Notice.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'Roboto',
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NoticePage(),
    );
  }
}

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
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

  void fetchNotices() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('notices')
        .where('noticeType', isEqualTo: selectedType)
        .orderBy('date', descending: true)
        .get();
    setState(() {
      notices = querySnapshot.docs
          .map((doc) => Notice.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  void fetchGeneralNotices() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('generalNotices')
        .where('noticeType', isEqualTo: selectedType)
        .orderBy('date', descending: true)
        .limit(14)
        .get();
    setState(() {
      generalNotices.addAll(querySnapshot.docs
          .map((doc) =>
              GeneralNotice.fromJson(doc.data() as Map<String, dynamic>))
          .toList());
      generalNoticePage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("공지사항",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.lightBlue[100],
          centerTitle: true // 하늘색 배경
          ),
      backgroundColor: Colors.white, // 전체 배경을 흰색으로 설정
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeButton("ACADEMIC", "학사안내"),
              _buildTypeButton("EVENT", "행사안내"),
              _buildTypeButton("NORMAL", "일반소식"),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
                  notices.length + generalNotices.length + 2, // 구분선 및 섹션 헤더 포함
              itemBuilder: (context, index) {
                if (index == 0) {
                  // notices 섹션 구분 헤더
                  return _buildSectionHeader("공지사항");
                } else if (index == notices.length + 1) {
                  // generalNotices 세션 구분 헤더
                  return _buildSectionHeader("일반 소식");
                } else if (index < notices.length) {
                  return _buildNoticeTile(notices[index]);
                } else {
                  int generalIndex = index - notices.length - 2;
                  if (generalIndex >= 0 &&
                      generalIndex < generalNotices.length) {
                    final generalNotice = generalNotices[generalIndex];
                    return _buildGeneralNoticeTile(generalNotice);
                  } else {
                    return SizedBox(); // 범위를 벗어나면 빈 위젯 반환
                  }
                }
              },
              controller: ScrollController()
                ..addListener(() {
                  if (generalNoticePage * 5 > generalNotices.length) {
                    fetchGeneralNotices();
                  }
                }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, String label) {
    bool isSelected = selectedType == type; // 선택된 버튼인지 확인
    return ElevatedButton(
      onPressed: isSelected
          ? null // 이미 선택된 버튼은 비활성화
          : () {
              setState(() {
                selectedType = type;
                notices.clear();
                generalNotices.clear();
                generalNoticePage = 0;
                fetchNotices();
                fetchGeneralNotices();
              });
            },
      style: ElevatedButton.styleFrom(
        foregroundColor:
            isSelected ? Colors.blue : Colors.grey[300], // 선택된 버튼 색상 변경
      ),
      child: Text(label, style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildNoticeTile(Notice notice) {
    return Column(
      children: [
        ListTile(
          title: Text(notice.title),
          subtitle: Text(notice.date),
          onTap: () => _launchUrl(notice.url),
        ),
        Divider(), // 공지사항 구분선
      ],
    );
  }

  Widget _buildGeneralNoticeTile(GeneralNotice notice) {
    return Column(
      children: [
        ListTile(
          title: Text(notice.title),
          subtitle: Text(notice.date),
          onTap: () => _launchUrl(notice.url),
        ),
        Divider(), // 일반 소식 구분선
      ],
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
    final Uri uri = Uri.parse(url); // URL을 Uri 객체로 변환
    if (await canLaunchUrl(uri)) {
      // canLaunchUrl로 URL을 실행할 수 있는지 확인
      await launchUrl(uri); // launchUrl로 URL을 실행
    } else {
      throw 'Could not launch $url';
    }
  }
}
