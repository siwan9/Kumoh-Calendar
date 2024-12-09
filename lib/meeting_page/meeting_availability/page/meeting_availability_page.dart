import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../add_meeting/page/add_metting_page.dart'; // AddMeetingPage의 경로를 맞춰주세요.

class MeetingAvailabilityPage extends StatefulWidget {
  Map<String, dynamic> meetingData;

  MeetingAvailabilityPage({
    super.key,
    required this.meetingData,
  });

  @override
  _MeetingAvailabilityPageState createState() => _MeetingAvailabilityPageState();
}

class _MeetingAvailabilityPageState extends State<MeetingAvailabilityPage> {
  late DateTime _currentWeekStart; // 현재 주 시작일
  late DateTime _currentWeekEnd; // 현재 주 종료일
  late List<List<List<bool>>> _selectedSlots;
  late List<List<List<bool>>> _finalSelectedSlots;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late int totalWeeks;

  bool isEditMode = false;
  bool isFinalSchedule = false;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getMonday((widget.meetingData['start_date'] as Timestamp).toDate());
    _currentWeekEnd = _getSunday((widget.meetingData['start_date'] as Timestamp).toDate());

    // 주차 수 계산
    totalWeeks = _getTotalWeeks(widget.meetingData['start_date'].toDate(), widget.meetingData['finish_date'].toDate());

    // 3차원 배열 초기화 (주차 수, 요일 수, 슬롯 수)
    _selectedSlots = List.generate(totalWeeks, (index) => List.generate(7, (index) => List.filled(14, false)));
    _finalSelectedSlots = List.generate(totalWeeks, (index) => List.generate(7, (index) => List.filled(14, false)));
    // 현재 유저의 selected_slots 확인
    String? currentUserId = _auth.currentUser?.uid;
    var memberList = widget.meetingData['member_list'] as Map<String, dynamic>;

    // 현재 유저의 selected_slots가 비어있는지 확인
    if (memberList.containsKey(currentUserId)) {
      var currentUserSlots = memberList[currentUserId]['selected_slots'] as List<dynamic>?;
    
      // selected_slots가 존재할 경우 _selectedSlots에 반영
      if (currentUserSlots != null && currentUserSlots.isNotEmpty) {
        for (var slot in currentUserSlots) {
          String slotId = slot['slot_id'];
          
          // 슬롯 ID를 사용하여 _selectedSlots 업데이트
          int weekIndex = int.parse(slotId.split('slot')[0]);
          
          int slotIndex = int.parse(slotId.substring(slotId.indexOf('slot') + 4)); // 'slot' 이후의 숫자 추출
          int columnIndex = slotIndex ~/ 14; // 열 계산
          int rowIndex = slotIndex % 14; // 행 계산

          // 유효한 인덱스인지 확인하고 선택 상태 업데이트
          if (weekIndex >= 0 && weekIndex < totalWeeks && columnIndex >= 0 && columnIndex < 7 && rowIndex >= 0 && rowIndex < 14) {
            _selectedSlots[weekIndex][columnIndex][rowIndex] = true; // 선택 상태를 true로 설정
          }
        }
      } else {
        isEditMode = true; // 수정 모드를 true로 설정
      }
    }
  }
  int _getTotalWeeks(DateTime startDate, DateTime finishDate) {
    DateTime startOfWeek = startDate.subtract(Duration(days: startDate.weekday - 1));
    DateTime endOfWeek = finishDate.add(Duration(days: 7 - finishDate.weekday));
    return ((endOfWeek.difference(startOfWeek).inDays) ~/ 7) + 1;
  }
  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1)); // 해당 주의 월요일로 변경
  }
  DateTime _getSunday(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday)); // 해당 주의 일요일로 변경
  }

  bool _canNavigateToPreviousWeek() {
    DateTime previousWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    return previousWeekStart.isAfter(_getMonday((widget.meetingData['start_date'] as Timestamp).toDate()).subtract(const Duration(days: 1)));
  }
  bool _canNavigateToNextWeek() {
    DateTime nextWeekStart = _currentWeekStart.add(const Duration(days: 7));
    return nextWeekStart.isBefore(_getMonday((widget.meetingData['finish_date'] as Timestamp).toDate()).add(const Duration(days: 7)));
  }
  void _navigateToPreviousWeek() {
    if (_canNavigateToPreviousWeek()) {
      setState(() {
        _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
        _currentWeekEnd = _currentWeekEnd.subtract(const Duration(days: 7));
      });
    }
  }
  void _navigateToNextWeek() {
    if (_canNavigateToNextWeek()) {
      setState(() {
        _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
        _currentWeekEnd = _currentWeekEnd.add(const Duration(days: 7));
      });
    }
  }

  bool _isSelectable(int column) {
    DateTime day = _currentWeekStart.add(Duration(days: column));
    return day.isAfter((widget.meetingData['start_date'] as Timestamp).toDate().subtract(const Duration(days: 1))) && day.isBefore((widget.meetingData['finish_date'] as Timestamp).toDate().add(const Duration(days: 1)));
  }
  void _toggleSlot(int weekIndex, int column, int row) {
    if (isEditMode && _isSelectable(column)) {
      setState(() {
        _selectedSlots[weekIndex][column][row] = !_selectedSlots[weekIndex][column][row]; // 클릭된 슬롯의 선택 상태 토글
      });
    } else if (isFinalSchedule && _isSelectable(column)) {
      setState(() {
        _finalSelectedSlots[weekIndex][column][row] = !_finalSelectedSlots[weekIndex][column][row]; // 클릭된 슬롯의 선택 상태 토글
      });
    }
  }

  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1: return '월';
      case 2: return '화';
      case 3: return '수';
      case 4: return '목';
      case 5: return '금';
      case 6: return '토';
      case 7: return '일';
      default: return '';
    }
  }

  void _navigateToEditMeeting() {
    // member_list에서 selected_slots가 비어 있지 않은 유저 체크
    var memberList = widget.meetingData['member_list'] as Map<String, dynamic>;

    bool hasSelectedSlots = memberList.values.any((member) {
      if (member is Map<String, dynamic>) {
        var selectedSlots = member['selected_slots'] as List<dynamic>?;
        return selectedSlots != null && selectedSlots.isNotEmpty;
      }
      return false;
    });

    if (hasSelectedSlots) {
      // 수정할 수 없다는 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('수정할 수 없습니다. 선택된 슬롯이 있는 유저가 존재합니다.')));
    } else {
      // 수정 페이지로 이동하는 로직
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMeetingPage(meetingData: widget.meetingData)),
      );
    }
  }

  void _saveMeeting() async {
    final firestore = FirebaseFirestore.instance;
    String meetingId = widget.meetingData['id'];
    String? currentUserId = _auth.currentUser?.uid; // 현재 유저의 UID

    // 선택된 슬롯 정보를 저장할 리스트
    List<Map<String, dynamic>> selectedSlotsToSave = [];

    // 3차원 배열을 순회하여 선택된 슬롯을 확인
    for (int weekIndex = 0; weekIndex < totalWeeks; weekIndex++) {
      for (int column = 0; column < 7; column++) { // 7일
        for (int row = 0; row < 14; row++) { // 14개 시간 슬롯
          if (_selectedSlots[weekIndex][column][row]) { // 슬롯이 선택되었는지 확인
            DateTime selectedDate = _currentWeekStart.add(Duration(days: column)); // 선택된 날짜 계산
            String slotId = '${weekIndex}slot${column * 14 + row}'; // 슬롯 ID 생성

            // 저장할 슬롯 정보 추가
            selectedSlotsToSave.add({
              'date_time': DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 8 + row), // DateTime 객체 생성
              'slot_id': slotId, // 슬롯 ID
            });
          }
        }
      }
    }

    // Firestore에서 해당 미팅 문서 업데이트
    await firestore.collection('meeting_groups').doc(meetingId).update({
      'member_list.$currentUserId.selected_slots': selectedSlotsToSave, // 선택된 슬롯으로 기존 데이터를 덮어씁니다.
    });
    await _fetchMeetingData();

    setState(() {
      isEditMode = false;
    });

    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일정이 확정되었습니다.')),
    );
  }

  Color _getCellColor(int weekIndex, int column, int row) {
    if (!_isSelectable(column)) {
      return Colors.grey[300]!; // 선택 불가능한 날짜는 연한 회색
    }
    if (_selectedSlots[weekIndex][column][row]) {
      return Colors.green; // 선택된 슬롯의 색상
    }
    return Colors.transparent; // 기본 색상
  }
  Color _getDateColor(int weekIndex, int column, int row) {
    if (!_isSelectable(column)) {
      return Colors.grey[300]!; // 선택 불가능한 날짜는 연한 회색
    }

    int selectedCount = 0;
    int totalMembers = 0;

    // 모든 유저의 selected_slots를 확인하여 선택된 슬롯 수를 계산합니다.
    var memberList = widget.meetingData['member_list'] as Map<String, dynamic>;
    totalMembers = memberList.length;

    for (var member in memberList.values) {
      if (member is Map<String, dynamic>) {
        var selectedSlots = member['selected_slots'] as List<dynamic>?;

        if (selectedSlots != null) {
          for (var slot in selectedSlots) {
            String slotId = slot['slot_id'];
            
            if (slotId.startsWith('$weekIndex')) { // 주차에 맞는 슬롯 확인
              int slotIndex = int.parse(slotId.substring(slotId.indexOf('slot') + 4)); // 'slot' 이후의 숫자 추출
              int columnIndex = slotIndex ~/ 14; // 열 계산
              int rowIndex = slotIndex % 14; // 행 계산

              // column과 row가 모두 일치하는지 확인
              if (columnIndex == column && rowIndex == row) {
                selectedCount++;
              }
            }
          }
        }
      }
    }

    // 색상 결정
    if (selectedCount == 0) {
      return Colors.transparent; // 선택되지 않은 날짜
    } else {
      // 색상 값 계산 (연한 초록색에서 진한 초록색으로)
      double intensity = selectedCount / totalMembers; // 선택된 비율
      intensity = intensity.clamp(0.0, 1.0); // 0.0에서 1.0 사이로 제한


      Color lightGreen = const Color.fromARGB(255, 207, 239, 207); // 연한 초록색
      Color darkGreen = Colors.green; // 진한 초록색

      return Color.lerp(lightGreen, darkGreen, intensity)!; // 색상 보간
    }
  }
  Color _getFinalDateColor(int weekIndex, int column, int row) {
    if (!_isSelectable(column)) {
      return Colors.grey[300]!; // 선택 불가능한 날짜는 연한 회색
    }
    if (_finalSelectedSlots[weekIndex][column][row]) {
      return Colors.red; // 선택된 슬롯의 색상
    }
    return Colors.transparent; // 기본 색상
  }

  Future<void> _fetchMeetingData() async {
    final firestore = FirebaseFirestore.instance;
    String meetingId = widget.meetingData['id'];

    // Firestore에서 미팅 데이터 가져오기
    DocumentSnapshot meetingSnapshot = await firestore.collection('meeting_groups').doc(meetingId).get();

    if (meetingSnapshot.exists) {
      setState(() {
        Map<String, dynamic> data = meetingSnapshot.data() as Map<String, dynamic>;
        data['id'] = meetingSnapshot.id; // 고유 ID를 추가합니다.
        widget.meetingData = data;
      });
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('회의 삭제 확인'),
          content: const Text('이 회의를 정말로 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // 취소
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // 확인
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMeeting() async {
    final firestore = FirebaseFirestore.instance;
    String meetingId = widget.meetingData['id'];

    try {
      // meeting_groups에서 회의 삭제
      await firestore.collection('meeting_groups').doc(meetingId).delete();
      
      // 삭제 완료 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('회의가 삭제되었습니다.'),
      ));
      
      // 회의 삭제 후 이전 화면으로 돌아가기
      Navigator.of(context).pop(true);
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('회의 삭제 중 오류가 발생했습니다: $e'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    int currentWeekIndex = (_currentWeekStart.difference((widget.meetingData['start_date'] as Timestamp).toDate()).inDays ~/ 7);
    bool isMasterMember = widget.meetingData['master_member'] == _auth.currentUser?.uid;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.meetingData['name'] ?? '회의 이름 없음'),
          backgroundColor: Colors.white,
          actions: [
            if (isMasterMember)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: _navigateToEditMeeting,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black), // 휴지통 아이콘 추가
                    onPressed: () async {
                      // 삭제 확인 다이얼로그 표시
                      bool? confirmDelete = await _showDeleteConfirmationDialog(context);
                      if (confirmDelete == true) {
                        await _deleteMeeting(); // 회의 삭제 메서드 호출
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _canNavigateToPreviousWeek() ? _navigateToPreviousWeek : null,
                  ),
                  Expanded(
                    child: Text(
                      '${_currentWeekStart.year}년 ${_currentWeekStart.month}월 ${_currentWeekStart.day}일 ~ ${_currentWeekEnd.year}년 ${_currentWeekEnd.month}월 ${_currentWeekEnd.day}일',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _canNavigateToNextWeek() ? _navigateToNextWeek : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: List.generate(7, (column) {
                  DateTime day = _currentWeekStart.add(Duration(days: column));
                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${day.month}/${day.day}\n(${_getDayOfWeek(day)})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    children: List.generate(7, (column) {
                      return Expanded(
                        child: Column(
                          children: List.generate(14, (row) {
                            return GestureDetector(
                              onTap: () {
                                if (isMasterMember && isFinalSchedule) {
                                  // 마스터 사용자가 최종 일정을 선택할 때
                                  _toggleSlot(currentWeekIndex, column, row); // 슬롯 토글
                                } else if (isEditMode) {
                                  // 수정 모드일 때 슬롯 토글
                                  _toggleSlot(currentWeekIndex, column, row);
                                }
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  color: isMasterMember && isFinalSchedule
                                      ? _getFinalDateColor(currentWeekIndex, column, row)// 최종 일정 선택 시 빨간색
                                      : (isEditMode
                                        ? _getCellColor(currentWeekIndex, column, row) // 수정 모드일 때
                                        : _getDateColor(currentWeekIndex, column, row)), // 수정 모드 아닐 때
                                ),
                                child: Center(
                                  child: Text(
                                    '${8 + row} ${row < 4 ? 'AM' : 'PM'}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isFinalSchedule) 
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditMode = !isEditMode; // 수정 모드 토글
                      });
                    },
                    child: Text(isEditMode ? '취소하기' : '수정하기'), // 버튼 텍스트 변경
                  ),
                if (!isEditMode && isMasterMember) 
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isFinalSchedule = !isFinalSchedule; // 최종 일정 토글
                      });
                    },
                    child: Text(isFinalSchedule ? '취소하기' : '최종 일정 선택하기'),
                  ),
                if (isEditMode) // 수정 모드일 때만 저장하기 버튼 표시
                  ElevatedButton(
                    onPressed: _saveMeeting,
                    child: const Text('저장하기'),
                  ) else if (isFinalSchedule)
                    ElevatedButton(
                    onPressed: _confirmSchedule,
                    child: const Text('확정하기'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 일정 확정하기 메서드 구현
  void _confirmSchedule() async {
    final firestore = FirebaseFirestore.instance;
    String meetingId = widget.meetingData['id'];
    var memberList = widget.meetingData['member_list'] as Map<String, dynamic>;

    _currentWeekStart = _getMonday((widget.meetingData['start_date'] as Timestamp).toDate());
    DateTime? earliestDateTime;
    DateTime? latestDateTime; 
    // _finalSelectedSlots에서 선택된 슬롯 정보를 가져오기
    List<Map<String, dynamic>> finalSelectedSlots = [];
    for (int weekIndex = 0; weekIndex < _finalSelectedSlots.length; weekIndex++) {
      for (int column = 0; column < _finalSelectedSlots[weekIndex].length; column++) {
        for (int row = 0; row < _finalSelectedSlots[weekIndex][column].length; row++) {
          if (_finalSelectedSlots[weekIndex][column][row]) {
            // 슬롯이 선택된 경우
            DateTime selectedDate = _currentWeekStart.add(Duration(days: (weekIndex * 7) + column)); // 선택된 날짜 계산
            DateTime dateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              8 + row, // 8AM부터 시작
            );

            // 최종 선택된 슬롯 정보를 리스트에 추가
            finalSelectedSlots.add({
              'date_time': dateTime.toIso8601String(), // ISO 8601 형식으로 저장
            });

            // 가장 과거와 가장 미래의 날짜 및 시간 계산
            if (earliestDateTime == null || dateTime.isBefore(earliestDateTime)) {
              earliestDateTime = dateTime;
            }
            if (latestDateTime == null || dateTime.isAfter(latestDateTime)) {
              latestDateTime = dateTime;
            }
          }
        }
      }
    }

    // 각 멤버의 UID와 finalSelectedSlots를 schedule 테이블에 추가
    for (var entry in memberList.entries) {
      String memberId = entry.key; // 멤버의 UID

      // schedule 테이블에 데이터 추가
      await firestore.collection('schedules').add({
        'name' : widget.meetingData['name'],
        'place' : widget.meetingData['location'],
        'userId': memberId, // 사용자 UID
        'startDate': earliestDateTime?.toIso8601String(), // 가장 과거의 날짜
        'endDate': latestDateTime?.toIso8601String(), // 가장 미래의 날짜
        'memo': finalSelectedSlots.map((slot) => slot['date_time']).join(', '), // 모든 날짜 및 시간 정보를 메모로
      });
    }

    // meeting_groups 데이터 삭제
    await firestore.collection('meeting_groups').doc(meetingId).delete();

    // 일정 확정 완료 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('일정이 확정되었습니다.'),
    ));
    Navigator.of(context).pop(true);
  }


}
