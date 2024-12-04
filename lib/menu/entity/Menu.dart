class Menu {
  final String id;
  final String menuType; // MenuType (Enum 대신 String)
  final String date; // 날짜 (String 형식)
  final String dayOfWeek; // 요일 (Enum 대신 String)
  final String mealType; // MealType (Enum 대신 String)
  final List<String> contents; // 메뉴 내용 리스트

  Menu({
    required this.id,
    required this.menuType,
    required this.date,
    required this.dayOfWeek,
    required this.mealType,
    required this.contents,
  });

  // Firebase 문서를 Menu 객체로 변환
  factory Menu.fromJson(String id, Map<String, dynamic> json) {
    return Menu(
      id: id,
      menuType: json['menuType'] as String,
      date: json['date'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      mealType: json['mealType'] as String,
      contents: List<String>.from(json['contents'] as List<dynamic>),
    );
  }

  // Menu 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuType': menuType,
      'date': date,
      'dayOfWeek': dayOfWeek,
      'mealType': mealType,
      'contents': contents,
    };
  }
}
