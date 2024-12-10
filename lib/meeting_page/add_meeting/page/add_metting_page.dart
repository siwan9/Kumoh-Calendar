import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widget/title_field.dart';
import '../widget/save_button.dart';
import '../widget/date_time_row.dart';
import '../widget/location_field.dart';
import '../widget/user_input_field.dart';

class AddMeetingPage extends StatefulWidget {
  final Map<String, dynamic> meetingData;
  const AddMeetingPage({super.key, required this.meetingData});
  
  @override
  _AddMeetingPageState createState() => _AddMeetingPageState();
}

class _AddMeetingPageState extends State<AddMeetingPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<TextEditingController> _userControllers = [TextEditingController()];

  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now();
  
  List<List<String>> _suggestedUsers = [[]]; // 추천 사용자 목록 (각 입력 필드에 대해)
  int? _showSuggestionsIdx; // 추천 목록을 보여줄 입력 필드 인덱스

  @override
  void initState() {
    super.initState();
    
    // 전달된 회의 정보가 있을 경우 필드에 값 설정
    if (widget.meetingData.isNotEmpty) {
      _titleController.text = widget.meetingData['name'] ?? '';
      _locationController.text = widget.meetingData['location'] ?? '';
      _startDateTime = (widget.meetingData['start_date'] as Timestamp).toDate();
      _endDateTime = (widget.meetingData['finish_date'] as Timestamp).toDate();


      // 사용자 이메일 목록 설정
      if (widget.meetingData['member_list'] != null) {
        List<String> memberIds = List<String>.from(widget.meetingData['member_list'].keys);
        String? userId = FirebaseAuth.instance.currentUser?.uid;
  
        if (userId != null && memberIds.last == userId) {
          memberIds.removeLast(); // 마지막 요소 제거
        }
        _getUserEmailsByIds(memberIds); // 사용자 ID를 기반으로 이메일 가져오기
      }
    }
  }
  Future<void> _getUserEmailsByIds(List<String> memberIds) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: memberIds) // 사용자 ID로 이메일 검색
          .get();

      setState(() {
        _userControllers.clear(); // 기존의 입력 필드 초기화
        _suggestedUsers.clear(); // 기존의 추천 사용자 목록 초기화

        for (var doc in querySnapshot.docs) {
          String email = doc['email'] as String;
          _userControllers.add(TextEditingController(text: email)); // 이메일로 텍스트 필드 초기화
          _suggestedUsers.add([]); // 추천 사용자 목록 초기화
        }
        
        // 첫 번째 입력 필드가 없다면 기본적으로 추가
        if (_userControllers.isEmpty) {
          _userControllers.add(TextEditingController());
          _suggestedUsers.add([]); // 첫 번째 필드의 추천 사용자 목록 초기화
        }
      });
    } catch (e) {
      print('사용자 이메일 가져오기 중 오류 발생: $e');
    }
  }

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
            LocationField(controller: _locationController),
            const Divider(color: Colors.grey, thickness: 1),
            ..._buildUserInputFields(),
            const SizedBox(height: 8),
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
      if (_validateInputs()) return;

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        _showSnackBar('사용자 정보를 찾을 수 없습니다.');
        return;
      }

      List<String> memberEmails = _userControllers.map((controller) => controller.text.trim()).toList();
      List<String> memberIds = await getUserIdsByEmails(memberEmails);
      memberIds.add(userId);

      if (memberIds.isEmpty) {
        _showSnackBar('회의 멤버가 필요합니다.');
        return;
      }

      // 회의 데이터가 비어있으면 새로 생성, 그렇지 않으면 수정
      if (widget.meetingData.isNotEmpty) {
        await _updateMeetingData(memberIds); // 수정
      } else {
        await _saveMeetingData(memberIds); // 새로 저장
      }
    },
  );
}

bool _validateInputs() {
  // 필수 입력 필드 체크
  if (_titleController.text.isEmpty || _locationController.text.isEmpty ||
      _userControllers.any((controller) => controller.text.isEmpty)) {
    _showSnackBar('모든 필드를 올바르게 채워주세요.');
    return true;
  }

  // 날짜 체크
  if (_endDateTime.isBefore(_startDateTime)) {
    _showSnackBar('종료 날짜는 시작 날짜 이후여야 합니다.');
    return true;
  }

  // 로그인한 사용자 이메일 확인
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  if (userEmail != null && _userControllers.any((controller) => controller.text.trim() == userEmail)) {
    _showSnackBar('본인은 회의 멤버로 추가할 수 없습니다.');
    return true;
  }

  // 동일한 유저 이메일 확인
  Set<String> uniqueEmails = {};
  for (var controller in _userControllers) {
    String email = controller.text.trim();
    if (email.isNotEmpty) {
      if (uniqueEmails.contains(email)) {
        _showSnackBar('동일한 이메일을 여러 번 추가할 수 없습니다: $email');
        return true;
      }
      uniqueEmails.add(email);
    }
  }
  return false; // 모든 검증 통과
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<Widget> _buildUserInputFields() {
    return List.generate(_userControllers.length, (index) {
      TextEditingController controller = _userControllers[index];

      return UserInputField(
        controller: controller,
        onChanged: (value) async {
          await _searchUsers(value, index);
          setState(() {
            if (_suggestedUsers[index].isNotEmpty) {
              _showSuggestionsIdx = index; // 추천 목록 표시
            } else {
              _showSuggestionsIdx = null; // 추천 목록 숨김
            }
          });
        },
        showSuggestionsIdx: _showSuggestionsIdx == index ? index : -1,
        onRemove: index > 0 ? () => _removeUserInputField(index) : null,
        suggestedUsers: _suggestedUsers[index],
        onSelectUser: (user) {
          controller.text = user; // 선택한 사용자 이름을 해당 입력 필드에 추가
          setState(() {
            _suggestedUsers[index].clear(); // 추천 목록 초기화
            _showSuggestionsIdx = null; // 추천 목록 숨기기
          });
        },
      );
    });
  }

  Future<void> _searchUsers(String query, int index) async {
    if (query.isEmpty) {
      setState(() {
        _suggestedUsers[index] = []; // 빈 문자열 시 추천 목록 초기화
      });
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      String? userEmail = FirebaseAuth.instance.currentUser?.email;
      setState(() {
        _suggestedUsers[index] = querySnapshot.docs
            .map((doc) => doc['email'] as String)
            .where((user) => user != userEmail && user.contains(query))
            .toList();
      });
    } catch (e) {
      print('사용자 검색 중 오류 발생: $e');
      setState(() {
        _suggestedUsers[index] = []; // 오류 발생 시 추천 목록 초기화
      });
    }
  }

  void _removeUserInputField(int index) {
    setState(() {
      _userControllers[index].dispose();
      _userControllers.removeAt(index);
      _suggestedUsers.removeAt(index); // 해당 인덱스의 추천 사용자 목록도 제거
    });
  }

  void _addUserInputField() {
    setState(() {
      _userControllers.add(TextEditingController());
      _suggestedUsers.add([]); // 새로운 입력 필드에 대해 추천 사용자 목록 초기화
    });
  }

  Future<List<String>> getUserIdsByEmails(List<String> emails) async {
    List<String> userIds = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereIn: emails) // 이메일 목록을 기준으로 검색
          .get();

      for (var doc in querySnapshot.docs) {
        userIds.add(doc.id); // UID를 리스트에 추가
      }
    } catch (e) {
      print('사용자 ID 가져오기 중 오류 발생: $e');
    }

    return userIds; // 사용자 ID 리스트 반환
  }

  Future<void> _saveMeetingData(List<String> memberIds) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        _showSnackBar('사용자 정보를 찾을 수 없습니다.');
        return;
      }

      await FirebaseFirestore.instance.collection('meeting_groups').add({
        'name': _titleController.text,
        'start_date': _startDateTime,
        'finish_date': _endDateTime,
        'location': _locationController.text,
        'master_member': userId,
        'member_list': {
          for (String memberId in memberIds) // memberIds를 기반으로 반복
            memberId: {
              'selected_slots': []
             }, // 빈 배열로 초기화
        },
        'created_at': FieldValue.serverTimestamp()
      });

      _showSnackBar('저장되었습니다.');
      Navigator.pop(context, true);
    } catch (e) {
      print('Firestore 저장 중 오류 발생: $e');
      _showSnackBar('저장 중 오류가 발생했습니다.');
    }
  }
  Future<void> _updateMeetingData(List<String> memberIds) async {
    try {
      String? meetingId = widget.meetingData['id']; // 회의 ID 가져오기

      await FirebaseFirestore.instance.collection('meeting_groups').doc(meetingId).update({
        'name': _titleController.text,
        'start_date': _startDateTime,
        'finish_date': _endDateTime,
        'location': _locationController.text,
        'member_list': {
          for (String memberId in memberIds) // memberIds를 기반으로 반복
            memberId: {
              'selected_slots': []
             }, // 빈 배열로 초기화
        },
      });

      _showSnackBar('수정되었습니다.');
      Navigator.pop(context, true);
    } catch (e) {
      print('Firestore 수정 중 오류 발생: $e');
      _showSnackBar('수정 중 오류가 발생했습니다.');
    }
  }
}
