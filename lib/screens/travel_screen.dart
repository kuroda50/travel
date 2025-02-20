import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/models/filter_params.dart';

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('旅へ行く'),
        ),
        body: ElevatedButton(
            onPressed: () {
              final filterParams = FilterParams(
                  hobbies: ["aaa"],
                  gender: "female",
                  ageMin: 0,
                  ageMax: 100);
              GoRouter.of(context).push('/account-list', extra: filterParams);
            },
            child: Text("次の画面へ")));
  }
}
