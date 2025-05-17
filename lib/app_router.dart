import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import '';
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

class AppRoutes {
  static const String sameHobby = '/';
  static const String accountCreate = '/account_create';
  static const String login = '/login';
  static const String travel = '/travel';
  static const String travelSearch = '/travel_search';
  static const String recruitmentList = '/recruitment_list';
  static const String recruitmentPost = '/recruitment_post';
  static const String recruitment = '/recruitment';
  static const String messageRoom = '/account';
  static const String accountList = '/account_list'; // 新規追加
  static const String message = '/message'; // 新規追加
  static const String followList = '/follow_list';
  static const String profile = '/profile';
  static const String setting = '/settings';
  static const String passwordChange = '/password_change';
  static const String passwordChange2 = '/password_change2';
  static const String emailChange = '/email_change';
  static const String termsOfUse = '/terms_of_use';
  static const String editProfile = '/edit_profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case accountCreate:
        return MaterialPageRoute(builder: (context) => AccountCreateScreen());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case travel:
        return MaterialPageRoute(builder: (context) => const TravelScreen());
      case travelSearch:
        return MaterialPageRoute(
          builder: (context) => TravelSearch(),
        );
      case recruitmentList:
        final args = settings.arguments as Map<String, dynamic>?;
        final postIds = args?['postIds'] as List<String>? ?? [''];
        return MaterialPageRoute(
            builder: (context) => RecruitmentListScreen(postIds: postIds));
      case recruitmentPost:
        return MaterialPageRoute(
            builder: (context) => const RecruitmentPostScreen());
      case recruitment:
        final args = settings.arguments as Map<String, dynamic>?;
        final postId = args?['postId'] as String? ?? '';
        return MaterialPageRoute(
            builder: (context) => RecruitmentScreen(postId: postId));
      case sameHobby:
        return MaterialPageRoute(builder: (context) => const SameHobbyScreen());
      case accountList:
        // 引数からフレンドIDを取得
        final args = settings.arguments as Map<String, dynamic>?;
        final userIds = args?['userIds'] as List<String>? ?? [''];
        return MaterialPageRoute(
          builder: (context) => AccountListScreen(userIds: userIds),
        );
      case message:
        return MaterialPageRoute(builder: (context) => const MessageScreen());
      case messageRoom:
        final args = settings.arguments as Map<String, dynamic>?;
        final extraData =
            args?['extraData'] as Map<String, dynamic>? ?? {"": ""};
        return MaterialPageRoute(
            builder: (context) => MessageRoomScreen(extraData: extraData));
      case followList:
        return MaterialPageRoute(
            builder: (context) => const FollowListScreen());
      case profile:
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String? ?? "";
        return MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: userId));
      case setting:
        return MaterialPageRoute(builder: (context) => const SettingsScreen());
      case passwordChange:
        return MaterialPageRoute(builder: (context) => const PasswordChangeScreen());
      case passwordChange2:
        return MaterialPageRoute(builder: (context) => const PasswordChangeScreen2());
      case emailChange:
        return MaterialPageRoute(builder: (context) => const EmailChangeScreen());
      case termsOfUse:
        return MaterialPageRoute(builder: (context) => const TermsOfUseScreen());
      case editProfile:
        return MaterialPageRoute(builder: (context) => const EditProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('ページが見つかりません: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
