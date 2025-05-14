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
import 'screens/my_profile_screen.dart';
import 'screens/others_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/password_change_screen.dart';
import 'screens/password_change_screen_2.dart';
import 'screens/terms_of_use_screen.dart';
import 'screens/login_screen.dart';
import 'screens/account_create_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'component/bottom_navigation_bar2.dart';

final GoRouter goRouter = GoRouter(
  initialLocation: '/travel',
  routes: [
    // ✅ タブ構造（状態保持）
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(index),
          ),
        );
      },
      branches: [
        // 🟠 タブ1: Travel
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/travel',
              name: 'travel',
              builder: (context, state) => const TravelScreen(),
              routes: [
                GoRoute(
                  path: 'travel_search',
                  name: 'travel_search',
                  builder: (context, state) => TravelSearch(),
                ),
                GoRoute(
                  path: '/same-hobby',
                  name: 'sameHobby',
                  builder: (context, state) => const SameHobbyScreen(),
                ),
                GoRoute(
                  path: '/account-list',
                  name: 'accountList',
                  builder: (context, state) => AccountListScreen(
                    userIds: state.extra! as List<String>,
                  ),
                ),
                GoRoute(
                  path: '/recruitment-list',
                  name: 'recruitment-list',
                  builder: (context, state) => RecruitmentListScreen(
                      postIds: state.extra! as List<String>),
                ),
              ],
            ),
          ],
        ),
        // 🟠 タブ2: Recruitment
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recruitment-post',
              name: 'recruitmentPost',
              builder: (context, state) => const RecruitmentPostScreen(),
            ),
          ],
        ),
        // 🟠 タブ3: Message
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/message',
              name: 'message',
              builder: (context, state) => const MessageScreen(),
            ),
          ],
        ),
        // 🟠 タブ4: Follow
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/follow-list',
              name: 'followList',
              builder: (context, state) => const FollowListScreen(),
            ),
          ],
        ),
        // 🟠 タブ5: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my_profile',
              name: 'profile',
              builder: (context, state) => const MyProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // ✅ タブ外ページ
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/account-create',
      name: 'accountCreate',
      builder: (context, state) => AccountCreateScreen(),
    ),
    GoRoute(
      path: '/password-change',
      name: 'passwordChange',
      builder: (context, state) => const PasswordChangeScreen(),
    ),
    GoRoute(
      path: '/password-change-2',
      name: 'passwordChange2',
      builder: (context, state) => const PasswordChangeScreen2(),
    ),
    GoRoute(
      path: '/email-change',
      name: 'emailChange',
      builder: (context, state) => const EmailChangeScreen(),
    ),
    GoRoute(
      path: '/terms-of-use',
      name: 'termsOfUse',
      builder: (context, state) => const TermsOfUseScreen(),
    ),
    GoRoute(
      path: '/recruitment',
      name: 'recruitment',
      builder: (context, state) =>
          RecruitmentScreen(postId: state.extra! as String),
    ),
    GoRoute(
      path: '/message-room',
      name: 'message-room',
      builder: (context, state) => MessageRoomScreen(
        extraData: state.extra! as Map<String, dynamic>,
      ),
    ),
    GoRoute(
      path: '/edit_profile',
      name: 'editProfile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/others-profile',
      name: 'othersProfile',
      builder: (context, state) => OthersProfileScreen(
        userId: state.extra! as String,
      ),
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
