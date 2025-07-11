import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel/screens/email_change_screen.dart';

import 'screens/travel_search.dart';
import 'screens/travel_screen.dart';
import 'screens/recruitment_list_screen.dart';
import 'screens/recruitment_post_screen.dart';
import 'screens/recruitment_screen.dart';
import 'screens/same_hobby_screen.dart';
import 'screens/account_list_screen.dart';
import 'screens/message_screen.dart';
import 'screens/message_room_screen.dart';
import 'screens/follow_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/password_change_screen.dart';
import 'screens/password_change_screen_2.dart';
import 'screens/terms_of_use_screen.dart';
import 'screens/login_screen.dart';
import 'screens/account_create_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'component/bottom_navigation_bar.dart';

final GoRouter goRouter = GoRouter(
  initialLocation: '/travel',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: LoginScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/account-create',
      name: 'accountCreate',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AccountCreateScreen(),
      ),
    ),
    GoRoute(
      path: '/travel',
      name: 'travel',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: TravelScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/recruitment-list',
      name: 'recruitmentList',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: CustomBottomNavigationBar(
          child: RecruitmentListScreen(postIds: state.extra! as List<String>),
        ),
      ),
    ),
    GoRoute(
      path: '/travel_search',
      name: 'travel_search',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: CustomBottomNavigationBar(
          child: TravelSearch(),
        ),
      ),
    ),
    GoRoute(
      path: '/recruitment-post',
      name: 'recruitmentPost',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: RecruitmentPostScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/recruitment',
      name: 'recruitment',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: CustomBottomNavigationBar(
          child: RecruitmentScreen(postId: state.extra! as String),
        ),
      ),
    ),
    GoRoute(
      path: '/same-hobby',
      name: 'sameHobby',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: SameHobbyScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/account-list',
      name: 'accountList',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: CustomBottomNavigationBar(
          child: AccountListScreen(userIds: state.extra! as List<String>),
        ),
      ),
    ),
    GoRoute(
      path: '/message',
      name: 'message',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: MessageScreen(),
        ),
      ),
    ),
    GoRoute(
        path: '/message-room',
        name: 'message-room',
        pageBuilder: (context, state) {
          return NoTransitionPage(
            key: state.pageKey,
            child: CustomBottomNavigationBar(
              child: MessageRoomScreen(
                extraData: state.extra! as Map<String, dynamic>,
              ),
            ),
          );
        }),
    GoRoute(
      path: '/follow-list',
      name: 'followList',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: FollowListScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/profile/:userId', // userId を URL パラメータとして受け取る
      name: 'profile',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: CustomBottomNavigationBar(
          child: ProfileScreen(
              userId:
                  state.pathParameters['userId']!), // URL パラメータから userId を取得
        ),
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: SettingsScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/password-change',
      name: 'passwordChange',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: PasswordChangeScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/password-change-2',
      name: 'passwordChange2',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: PasswordChangeScreen2(),
        ),
      ),
    ),
    GoRoute(
      path: '/email-change',
      name: 'emailChange',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: EmailChangeScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/terms-of-use',
      name: 'termsOfUse',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomBottomNavigationBar(
          child: TermsOfUseScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/edit-profile',
      name: 'editProfile',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const EditProfileScreen(),
      ),
    ),
  ],
  errorPageBuilder: (context, state) => NoTransitionPage(
    key: state.pageKey,
    child: Scaffold(
      body: Center(
        child: Text('ページが見つかりません: ${state.uri.toString()}'),
      ),
    ),
  ),
);
