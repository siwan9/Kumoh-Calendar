import 'package:flutter/material.dart';

class UserInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function? onRemove;
  final List<String> suggestedUsers;
  final int showSuggestionsIdx;
  final Function(String) onSelectUser;

  const UserInputField({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onRemove,
    required this.suggestedUsers,
    required this.showSuggestionsIdx,
    required this.onSelectUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '사용자 이름',
              border: InputBorder.none,
            ),
            onChanged: onChanged,
          ),
          trailing: onRemove != null
              ? IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () => onRemove!(),
                )
              : null,
        ),
        if (showSuggestionsIdx >= 0) // 추천 사용자 목록이 있을 경우
          Container(
            padding: const EdgeInsets.only(left: 50.0),
            child: Column(
              children: suggestedUsers.map((user) {
                return ListTile(
                  title: Text(user),
                  onTap: () {
                    onSelectUser(user); // 입력 필드에 사용자 이름 추가
                  },
                );
              }).toList(),
            ),
          ),
        const Divider(color: Colors.grey, thickness: 1), // 구분선
      ],
    );
  }
}
