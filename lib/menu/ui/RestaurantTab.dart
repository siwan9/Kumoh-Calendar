// 중복 코드는 생략
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
            // 상단 버튼: 식당/기숙사/분식당 선택
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryButton('식당'),
                  const SizedBox(width: 16),
                  _buildCategoryButton('기숙사'),
                  const SizedBox(width: 16),
                  _buildCategoryButton('분식당'),
                ],
              ),
            ),

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
                    final filteredData = _filterDataByCategory(groupedData);

                    return selectedCategory == '분식당'
                        ? _buildSnackList(filteredData)
                        : _buildRestaurantList(filteredData);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 버튼 생성 함수
  Widget _buildCategoryButton(String category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor:
            selectedCategory == category ? Colors.blue : Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(category, style: const TextStyle(fontSize: 16)),
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

  Widget _buildRestaurantList(Map<String, Map<String, List<String>>> data) {
    return ListView(
      children: data.entries.map((entry) {
        return _buildRestaurantCard(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildSnackList(Map<String, Map<String, List<String>>> data) {
    final snackMenu = data["분식당"]?["일품요리"] ?? [];
    if (snackMenu.isEmpty) {
      return const Center(
          child: Text('분식당 메뉴가 없습니다.', style: TextStyle(fontSize: 16)));
    }

    return ListView(
      children: [
        _buildRestaurantCard("분식당", {"일품요리": snackMenu}),
      ],
    );
  }

  Widget _buildRestaurantCard(
      String restaurantName, Map<String, List<String>> meals) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(restaurantName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ..._buildMealRows(meals),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMealRows(Map<String, List<String>> meals) {
    List<Widget> mealWidgets = [];
    meals.forEach((mealTime, menuList) {
      if (menuList.isNotEmpty) {
        mealWidgets.add(Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mealTime,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...menuList.map(
                  (menu) => Text(menu, style: const TextStyle(fontSize: 16))),
            ],
          ),
        ));
      }
    });
    return mealWidgets;
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
