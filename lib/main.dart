import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kumoh_calendar/user_page/option_page.dart';
import 'firebase_options.dart';
import 'calendar_page/page.dart';
import 'meeting_page/meeting_schedule/page/meeting_schedule_page.dart';
import 'user_page/signin_page.dart';
import './menu/ui/RestaurantTab.dart';
import 'notice_page/ui/NoticeUI.dart';

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
      debugShowCheckedModeBanner: false,
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
  Widget _title = const Text('Kumoh-Calendar');
  List<Widget> _actions = [];

  void setTitle(Widget title) {
    setState(() {
      _title = title;
    });
  }

  void setActions(List<Widget> actions) {
    setState(() {
      _actions = actions;
    });
  }

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CalendarPage(setTitle: setTitle, setMenu: setActions),
      RestaurantTab(setTitle: setTitle, setMenu: setActions),
      NoticePage(setTitle: setTitle, setMenu: setActions),
      MeetingSchedulePage(setTitle: setTitle, setMenu: setActions),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title,
        backgroundColor: Colors.white,
        actions: [
          ..._actions,
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black, size: 32,), // 옵션 아이콘
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OptionsPage(),
              ),
            ), // 옵션 페이지로 이동
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _pages[_currentIndex], // 현재 선택된 페이지 표시
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: '일정'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '학식단'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: '학교공지'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: '그룹일정'),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
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
