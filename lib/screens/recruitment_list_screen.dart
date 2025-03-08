import 'package:flutter/material.dart';
import 'package:travel/component/header.dart';

class RecruitmentListScreen extends StatelessWidget {
  RecruitmentListScreen({super.key});

  final List<Map<String, String>> posts = List.generate(
    20,
    (index) => {
      "title": "2週間でアメリカ、カナダ巡り",
      "age": "20才～35才",
      "location": "アメリカ、カナダ",
      "user": "てつろう、20才",
      "date": "2025/04/01 ～ 2025/04/30",
      "day": "金土日",
    },
  );

  final bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post["title"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.group, color: Colors.blue, size: 16),
                            const SizedBox(width: 5),
                            Text(post["age"]!),
                            const SizedBox(width: 10),
                            Icon(Icons.photo, color: Colors.orange, size: 16),
                            const SizedBox(width: 5),
                            const Text("写真あり"),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(post["location"]!),
                        const SizedBox(height: 5),
                        Text(post["user"]!),
                        const SizedBox(height: 5),
                        Text("${post["date"]!}  ${post["day"]!}"),
                      ],
                    ),
                  ),
                  // ブックマークボタン
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.favorite : Icons.favorite_border,
                      color: isBookmarked ? Colors.red : Colors.grey,
                    ),
                    onPressed: (){},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
