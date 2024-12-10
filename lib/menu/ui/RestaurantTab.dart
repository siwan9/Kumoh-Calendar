// 중복 코드는 생략
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kumoh_calendar/menu/service/MenuService.dart';
import 'package:kumoh_calendar/menu/entity/Menu.dart';

class RestaurantTab extends StatefulWidget {
  const RestaurantTab(
      {super.key, required this.setTitle, required this.setMenu});

  final Function(Widget) setTitle;
  final Function(List<Widget>) setMenu;

  @override
  State<RestaurantTab> createState() => _RestaurantTabState();
}

class _RestaurantTabState extends State<RestaurantTab> {
  final MenuService menuService = MenuService();
  String selectedDate = DateTime.now().toLocal().toString().split(' ')[0];
  String selectedCategory = '식당'; // 기본 카테고리는 '식당'

  // 날짜 형식 변환
  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy MM dd').format(parsedDate);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setTitle(Text(formatDate(selectedDate)));
      widget.setMenu([
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousDay,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _nextDay,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // 데이터 표시
            Expanded(
              child: FutureBuilder<List<Menu>>(
                future: _getMenusForDay(selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('데이터가 없습니다.'));
                  } else {
                    // 데이터 필터링 및 렌더링
                    final groupedData = _groupMenusByRestaurant(snapshot.data!);

                    return ListView(
                      children: [
                        _buildRestaurantList("조식", groupedData),
                        _buildRestaurantList("중식", groupedData),
                        _buildRestaurantList("석식", groupedData),
                        _buildRestaurantList("일품요리", groupedData),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Menu>> _getMenusForDay(String date) async {
    return await menuService.getMenus(date);
  }

  // 식당 목록 그룹화
  Map<String, Map<String, List<String>>> _groupMenusByRestaurant(
      List<Menu> menus) {
    Map<String, Map<String, List<String>>> groupedData = {};

    for (var menu in menus) {
      String restaurantName = _translateRestaurant(menu.menuType);
      String mealTime = _translateMealTime(menu.mealType);

      // 분식당은 따로 처리
      if (menu.menuType == "SNACK") {
        mealTime = "일품요리";
      }

      groupedData.putIfAbsent(
        restaurantName,
        () => {"조식": [], "중식": [], "석식": [], "일품요리": []},
      );

      if (menu.mealType == "SNACK_TYPE") {
        groupedData[restaurantName]!["일품요리"]?.addAll(menu.contents);
      } else {
        groupedData[restaurantName]![mealTime]?.addAll(menu.contents);
      }
    }

    return groupedData;
  }

  // 데이터 필터링
  Map<String, Map<String, List<String>>> _filterDataByCategory(
      Map<String, Map<String, List<String>>> groupedData) {
    if (selectedCategory == '식당') {
      return {
        "학생식당": groupedData["학생식당"]!,
        "교직원식당": groupedData["교직원식당"]!,
      };
    } else if (selectedCategory == '기숙사') {
      return {
        "푸름 식당": groupedData["푸름 식당"]!,
        "오름1식당": groupedData["오름1식당"]!,
        "오름3식당": groupedData["오름3식당"]!,
      };
    } else {
      return {
        "분식당": groupedData["분식당"]!,
      };
    }
  }

  // 시간대별 필터링
  Map<String, List<String>> _filterDataByMealTime(
      Map<String, Map<String, List<String>>> groupedData, String mealTime) {
    Map<String, List<String>> result = {};

    for (var entry in groupedData.entries) {
      String restaurantName = entry.key;
      if (((restaurantName == "분식당") == (mealTime != "일품요리")) ||
          restaurantName != "학생식당" && mealTime == "조식" ||
          restaurantName == "학생식당" && mealTime == "석식") {
        continue;
      }
      if (entry.value.containsKey(mealTime) &&
          entry.value[mealTime]!.isNotEmpty) {
        result.putIfAbsent(restaurantName, () => entry.value[mealTime]!);
      } else {
        result.putIfAbsent(restaurantName, () => ["식당 운영 없음"]);
      }
    }

    return result;
  }

  String _translateRestaurant(String englishName) {
    switch (englishName) {
      case "STUDENT":
        return "학생식당";
      case "STAFF":
        return "교직원식당";
      case "SNACK":
        return "분식당";
      case "PUREUM":
        return "푸름 식당";
      case "OREUM1":
        return "오름1식당";
      case "OREUM3":
        return "오름3식당";
      default:
        return englishName;
    }
  }

  String _translateMealTime(String englishMealTime) {
    switch (englishMealTime) {
      case "BREAKFAST":
        return "조식";
      case "LUNCH":
        return "중식";
      case "DINNER":
        return "석식";
      case "SNACK_TYPE":
        return "일품요리";
      default:
        return englishMealTime;
    }
  }

  Widget _buildRestaurantList(
      String mealTime, Map<String, Map<String, List<String>>> data) {
    final filteredData = _filterDataByMealTime(data, mealTime);
    print(filteredData.toString());

    var maxMealCount = max(
        filteredData.values
            .map((value) => value.length)
            .reduce((value, element) => value > element ? value : element),
        2);
        print(maxMealCount);

    return SizedBox(
        height: 50 + 55 + 22 * maxMealCount.toDouble(),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(51, 0, 128, 255),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(mealTime,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                    height: 55 + 22 * maxMealCount.toDouble(),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: filteredData.entries.map((entry) {
                        return _buildRestaurantCard(entry.key, entry.value,
                            filteredData.entries.length == 1);
                      }).toList(),
                    ))
              ],
            )));
  }

  Widget _buildRestaurantCard(
      String restaurantName, List<String> mealList, bool isSingle) {
    return SizedBox(
        width: isSingle ? MediaQuery.of(context).size.width - 24 : 250,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          elevation: 0,
          color: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurantName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                _buildMealRows(mealList),
              ],
            ),
          ),
        ));
  }

  Widget _buildMealRows(List<String> mealList) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...mealList
              .map((menu) => Text(menu, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _previousDay() {
    setState(() {
      selectedDate = DateTime.parse(selectedDate)
          .subtract(const Duration(days: 1))
          .toString()
          .split(' ')[0];
      widget.setTitle(Text(formatDate(selectedDate)));
    });
  }

  void _nextDay() {
    setState(() {
      selectedDate = DateTime.parse(selectedDate)
          .add(const Duration(days: 1))
          .toString()
          .split(' ')[0];
      widget.setTitle(Text(formatDate(selectedDate)));
    });
  }
}
