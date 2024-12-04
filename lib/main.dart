import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kumoh_calendar/user_page/option_page.dart';
import 'firebase_options.dart';
import 'calendar_page/page.dart';
import 'meeting_page/meeting_schedule/page/meeting_schedule_page.dart';
import 'user_page/signin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kumoh Calendar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InitialPage(), // 초기 페이지로 InitialPage 설정
    );
  }
}

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          // 로그인 상태에 따라 페이지 전환
          if (snapshot.hasData) {
            return const HomePage(); // 로그인된 경우 홈 페이지
          } else {
            return const SigninPage(); // 로그인되지 않은 경우 로그인 페이지
          }
        }
        return const Center(child: CircularProgressIndicator()); // 로딩 중
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CalendarPage(),
    const MeetingSchedulePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kumoh-Calendar'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black), // 옵션 아이콘
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OptionsPage(),
              ),
            ), // 옵션 페이지로 이동
          ),
        ],
      ),
      body: _pages[_currentIndex], // 현재 선택된 페이지 표시
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '일정'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '학식단'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: '학교공지'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: '그룹일정'),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
