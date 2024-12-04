import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import'../widget/title_field.dart';
import'../widget/save_button.dart';
import '../widget/date_time_row.dart';
import '../widget/location_field.dart';
import '../widget/user_input_field.dart';


class AddMeetingPage extends StatefulWidget {
  const AddMeetingPage({super.key});
  @override
  _AddMeetingPageState createState() => _AddMeetingPageState();
}

class _AddMeetingPageState extends State<AddMeetingPage> {
  final TextEditingController _titleController = TextEditingController();
  DateTime _startDateTime = DateTime.now().copyWith(hour: 0, minute: 0);
  DateTime _endDateTime = DateTime.now().copyWith(hour: 0, minute: 0);
  final TextEditingController _locationController = TextEditingController();
  final List<TextEditingController> _userControllers = [TextEditingController()];

  List<String> _suggestedUsers = []; // 추천 사용자 목록
  int showSuggestionsIdx = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('제목 추가'),
        backgroundColor: Colors.white,
        actions: [_buildSaveButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            TitleField(controller: _titleController),
            const Divider(color: Colors.grey, thickness: 1),
            const SizedBox(height: 1),
            DateTimeRow(
              title: '시작 날짜',
              dateTime: _startDateTime,
              icon: Icons.calendar_today,
              isStartDate: true,
              onDateTimeChanged: (dateTime) {
                setState(() {
                  _startDateTime = dateTime;
                });
              },
            ),
            const Divider(color: Colors.grey, thickness: 1),
            const SizedBox(height: 1),
            DateTimeRow(
              title: '종료 날짜',
              dateTime: _endDateTime,
              icon: Icons.calendar_today,
              isStartDate: false,
              onDateTimeChanged: (dateTime) {
                setState(() {
                  _endDateTime = dateTime;
                });
              },
            ),
            const Divider(color: Colors.grey, thickness: 1),
            const SizedBox(height: 1),
            LocationField(controller: _locationController),
            const Divider(color: Colors.grey, thickness: 1),
            const SizedBox(height: 1),
            ..._buildUserInputFields(), // 사용자 입력 필드 추가
            const SizedBox(height: 8), // 추가 간격
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addUserInputField,
              tooltip: '사용자 추가',
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSaveButton() {
    return SaveButton(
      onPressed: () async {
        // 필수 입력 필드 체크
        if (_titleController.text.isEmpty || _locationController.text.isEmpty ||
            _userControllers.any((controller) => controller.text.isEmpty) ||
            await _checkUsernamesExist() == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('모든 필드를 올바르게 채워주세요.')),
          );
          return;
        }

        // 날짜 체크
        if (_endDateTime.isBefore(_startDateTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('종료 날짜는 시작 날짜 이후여야 합니다.')),
          );
          return;
        }

        // 본인 포함 체크
        String? userEmail = FirebaseAuth.instance.currentUser?.email;

        if (userEmail != null && _userControllers.any((controller) => controller.text.trim() == userEmail)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('본인은 회의 멤버로 추가할 수 없습니다.')),
          );
          return;
        }

        await _saveMeetingData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장되었습니다.')),
        );

        Navigator.pop(context);
      },
    );
  }


  List<Widget> _buildUserInputFields() {
    return _userControllers.asMap().entries.map((entry) {
      int index = entry.key;
      TextEditingController controller = entry.value;

      return UserInputField(
        controller: controller,
        onChanged: (value) async {
          await _searchUsers(value);
          setState(() {
            if (_suggestedUsers.isNotEmpty) {
              showSuggestionsIdx = index; // 추천 목록 표시 여부 업데이트
            }
          });
        },
        showSuggestionsIdx: showSuggestionsIdx,
        onRemove: index > 0 ? () => _removeUserInputField(index) : null,
        suggestedUsers: _suggestedUsers,
        onSelectUser: (user) {
          controller.text = user; // 입력 필드에 사용자 이름 추가
          setState(() {
            _suggestedUsers.clear(); // 추천 목록 초기화
            showSuggestionsIdx = -1; // 추천 목록 숨기기
          });
        },
      );
    }).toList();
  }

  Future<void> _searchUsers(String query) async {
    try {
      if (query.isEmpty) {
        setState(() {
          _suggestedUsers = []; // 빈 문자열 시 추천 목록 초기화
        });
        return;
      }
      // Firestore에서 사용자 이메일 검색
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // 검색된 사용자 이메일 리스트 만들기
      List<String> allUsers = querySnapshot.docs.map((doc) => doc['email'] as String).toList();

      String? userEmail = FirebaseAuth.instance.currentUser?.email;
      setState(() {
        _suggestedUsers = allUsers.where((user) => user != userEmail && user.contains(query)).toList();
      });
    } catch (e) {
      print('사용자 검색 중 오류 발생: $e');
      setState(() {
        _suggestedUsers = []; // 오류 발생 시 추천 목록 초기화
      });
    }
  }

  void _removeUserInputField(int index) {
    setState(() {
      _userControllers[index].dispose();
      _userControllers.removeAt(index);
    });
  }

  void _addUserInputField() {
    setState(() {
      _userControllers.add(TextEditingController());
    });
  }

  Future<bool> _checkUsernamesExist() async {
    try {
      for (TextEditingController controller in _userControllers) {
        String username = controller.text.trim();
        if (username.isNotEmpty) {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: username)
              .get();
          if (querySnapshot.docs.isEmpty) {
            return false; // 해당 닉네임이 존재하지 않음
          }
        }
      }
      return true; // 모든 닉네임이 존재함
    } catch (e) {
      print('사용자 확인 중 오류 발생: $e');
      return false; // 오류 발생 시 false 반환
    }
  }

  Future<List<String>> getUserIdsByEmails(List<String> emails) async {
    List<String> userIds = [];

    try {
      // Firestore에서 사용자 이메일로 검색
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereIn: emails) // 이메일 목록을 기준으로 검색
          .get();

      // 검색된 사용자 문서에서 UID 가져오기
      for (var doc in querySnapshot.docs) {
        userIds.add(doc.id); // UID를 리스트에 추가
      }
    } catch (e) {
      print('사용자 ID 가져오기 중 오류 발생: $e');
    }

    return userIds; // 사용자 ID 리스트 반환
  }

  Future<void> _saveMeetingData() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid; // 현재 사용자 ID 가져오기

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다.')),
        );
        return;
      }

      List<String> memberEmails = _userControllers.map((controller) => controller.text.trim()).toList();
      List<String> memberIds = await getUserIdsByEmails(memberEmails);
      memberIds.add(userId);

      // Firestore에 데이터 저장
      CollectionReference meetings = FirebaseFirestore.instance.collection('meeting_groups');
      await meetings.add({
        'name': _titleController.text,
        'start_date': _startDateTime,
        'finish_date': _endDateTime,
        'location': _locationController.text,
        'master_member': userId,
        'member_list': memberIds
      });
    } catch (e) {
      print('Firestore 저장 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 중 오류가 발생했습니다.')),
      );
    }
  }
}
