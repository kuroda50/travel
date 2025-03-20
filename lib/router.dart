import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/travel_screen.dart';
import 'screens/recruitment_list_screen.dart';
import 'screens/recruitment_post_screen.dart';
import 'screens/recruitment_screen.dart';
import 'screens/same_hobby_screen.dart';
import 'screens/account_list_screen.dart';
import 'screens/message_screen.dart';
import 'screens/message_send_screen.dart';
import 'screens/message_room_screen.dart';
import 'screens/follow_list_screen.dart';
import 'screens/follower_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/past_recruitment_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/password_change_screen.dart';
import 'screens/terms_of_use_screen.dart';
import 'screens/login_screen.dart';
import 'screens/account_create_screen.dart';

final GoRouter goRouter = GoRouter(
  initialLocation: '/travel', 
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/account-create',
      name: 'accountCreate',
      builder: (context, state) => const AccountCreateScreen(),
    ),
    GoRoute(
      path: '/travel',
      name: 'travel',
      builder: (context, state) => const TravelScreen(),
    ),
    GoRoute(
      path: '/recruitment-list',
      name: 'recruitmentList',
      builder: (context, state) => const RecruitmentListScreen(),
    ),
    GoRoute(
      path: '/recruitment-post',
      name: 'recruitmentPost',
      builder: (context, state) => const RecruitmentPostScreen(),
    ),
    GoRoute(
      path: '/same-hobby',
      name: 'sameHobby',
      builder: (context, state) => const SameHobbyScreen(),
    ),
    GoRoute(
      path: '/account-list',
      name: 'accountList',
      builder: (context, state) {
        final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
        final hobby = extra?['hobby'];
        final gender = extra?['gender'];
        final startAge = extra?['startAge'];
        final endAge = extra?['endAge'];

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchUsers(hobby, gender, startAge, endAge),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('エラー: ${snapshot.error}')),
              );
            }
            final users = snapshot.data ?? [];
            return AccountListScreen(users: users);
          },
        );
      },
    ),
    GoRoute(
      path: '/message',
      name: 'message',
      builder: (context, state) => const MessageScreen(),
    ),
    GoRoute(
      path: '/message-room',
      name: 'messageRoom',
      builder: (context, state) => const MessageRoomScreen(),
    ),
    GoRoute(
      path: '/follow-list',
      name: 'followList',
      builder: (context, state) => const FollowListScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('ページが見つかりません: ${state.uri.toString()}'),
    ),
  ),
);

Future<List<Map<String, dynamic>>> fetchUsers(String? hobby, String? gender, int? startAge, int? endAge) async {
  try {
    Query query = FirebaseFirestore.instance.collection('users');

    if (hobby != null && hobby.isNotEmpty) {
      query = query.where('hobby', isEqualTo: hobby);
    }
    if (gender != null && gender != 'どちらでも') {
      query = query.where('gender', isEqualTo: gender);
    }
    if (startAge != null) {
      query = query.where('age', isGreaterThanOrEqualTo: startAge);
    }
    if (endAge != null) {
      query = query.where('age', isLessThanOrEqualTo: endAge);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    print('Firestore取得エラー: $e');
    return [];
  }
}
