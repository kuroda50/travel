import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  initialLocation: '/account-create', 
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/account-create',
      name: 'accountCreate',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child:  AccountCreateScreen(),
      ),
    ),
    GoRoute(
      path: '/travel',
      name: 'travel',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const TravelScreen(),
      ),
    ),
    GoRoute(
      path: '/recruitment-list',
      name: 'recruitmentList',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const RecruitmentListScreen(),
      ),
    ),
    GoRoute(
      path: '/recruitment-post',
      name: 'recruitmentPost',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const RecruitmentPostScreen(),
      ),
    ),
    GoRoute(
      path: '/recruitment',
      name: 'recruitment',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const RecruitmentScreen(),
      ),
    ),
    GoRoute(
      path: '/same-hobby',
      name: 'sameHobby',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SameHobbyScreen(),
      ),
    ),
    GoRoute(
      path: '/account-list',
      name: 'accountList',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const AccountListScreen(),
      ),
    ),
    GoRoute(
      path: '/message',
      name: 'message',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const MessageScreen(),
      ),
    ),
    GoRoute(
      path: '/message-send',
      name: 'messageSend',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const MessageSendScreen(),
      ),
    ),
    GoRoute(
      path: '/message-room',
      name: 'messageRoom',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const MessageRoomScreen(),
      ),
    ),
    GoRoute(
      path: '/follow-list',
      name: 'followList',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const FollowListScreen(),
      ),
    ),
    GoRoute(
      path: '/follower-list',
      name: 'followerList',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const FollowerListScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const ProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/past-recruitment',
      name: 'pastRecruitment',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const PastRecruitmentScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/password-change',
      name: 'passwordChange',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const PasswordChangeScreen(),
      ),
    ),
    GoRoute(
      path: '/terms-of-use',
      name: 'termsOfUse',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const TermsOfUseScreen(),
      ),
    ),
  ],
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: Scaffold(
      body: Center(
        child: Text('ページが見つかりません: ${state.uri.toString()}'),
      ),
    ),
  ),
);
