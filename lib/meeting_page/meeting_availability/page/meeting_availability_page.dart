import 'package:flutter/material.dart';

class MeetingAvailabilityPage extends StatefulWidget {
  const MeetingAvailabilityPage({super.key});

  @override
  _MeetingAvailabilityPageState createState() => _MeetingAvailabilityPageState();
}

class _MeetingAvailabilityPageState extends State<MeetingAvailabilityPage> {
  final List<List<bool>> _selectedSlots = List.generate(7, (index) => List.filled(8, false));
  final List<List<int>> _availabilityCount = List.generate(7, (index) => List.filled(8, 0));

  bool _isDragging = false;
  int _startRow = -1;
  int _endRow = -1;
  int _selectedColumn = -1;

  void _onPanStart(DragStartDetails details, int column) {
    setState(() {
      _isDragging = true;
      _selectedColumn = column;
      _startRow = _getRowIndex(details.globalPosition);
      _endRow = _startRow;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    int rowIndex = _getRowIndex(details.globalPosition);
    if (_isDragging && rowIndex != -1) {
      setState(() {
        _endRow = rowIndex;
        for (int i = _startRow; i <= _endRow; i++) {
          _selectedSlots[_selectedColumn][i] = true;
          _availabilityCount[_selectedColumn][i]++;
        }
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _startRow = -1;
      _endRow = -1;
      _selectedColumn = -1;
    });
  }

  int _getRowIndex(Offset globalPosition) {
    // 각 시간대의 y 위치를 계산하여 행 인덱스를 반환
    for (int i = 0; i < 8; i++) {
      if (globalPosition.dy >= 100 + i * 50 && globalPosition.dy < 150 + i * 50) {
        return i;
      }
    }
    return -1; // 유효하지 않은 인덱스
  }

  Color _getCellColor(int column, int row) {
    if (_availabilityCount[column][row] > 0) {
      return Colors.green.withOpacity(0.1 + (_availabilityCount[column][row] * 0.1).clamp(0.0, 0.9));
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('정기회의'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Availability', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: List.generate(7, (column) {
                  return Expanded(
                    child: Column(
                      children: List.generate(8, (row) {
                        return GestureDetector(
                          onPanStart: (details) => _onPanStart(details, column),
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: _getCellColor(column, row),
                            ),
                            child: Center(
                              child: Text(
                                '${9 + row} ${row == 0 ? 'AM' : 'PM'}',
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 선택된 일정 확정 로직 추가
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('일정이 확정되었습니다.')),
                );
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
