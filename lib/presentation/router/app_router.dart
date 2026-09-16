import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_screen.dart';
import '../home/home_shell.dart';
import '../chat/chat_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';
import '../calls/active_call_screen.dart';
import '../search/search_screen.dart';
import '../groups/new_group_screen.dart';
import '../groups/group_info_screen.dart';

/// Route table for the whole app.
class AppRoutes {
  AppRoutes._();

  static const auth = '/auth';
  static const home = '/home';
  static const settings = '/settings';
  static const profile = '/profile';
  static const activeCall = '/call';
  static const search = '/search';
  static const newGroup = '/new-group';
  static const chat = '/chat';
  static const groupInfo = '/group-info';

  static String chatWith(String conversationId) => '$chat/$conversationId';
  static String profileWith(String userId) => '$profile/$userId';
  static String groupInfoWith(String conversationId) =>
      '$groupInfo/$conversationId';

  static String conversationOf(String path) =>
      path.startsWith('$chat/') ? path.substring('$chat/'.length) : '';
}

GoRouter buildRouter({
  required bool Function() isAuthenticated,
  Listenable? refreshListenable,
}) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authed = isAuthenticated();
      final loggingIn = state.matchedLocation == AppRoutes.auth;
      if (!authed && !loggingIn) return AppRoutes.auth;
      if (authed && loggingIn) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '${AppRoutes.chat}/:conversationId',
        builder: (context, state) {
          final id = state.pathParameters['conversationId'] ?? '';
          return ChatScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.groupInfo}/:conversationId',
        builder: (context, state) {
          final id = state.pathParameters['conversationId'] ?? '';
          return GroupInfoScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.profile}/:userId',
        builder: (context, state) {
          final id = state.pathParameters['userId'] ?? '';
          return ProfileScreen(userId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.activeCall}/:callId',
        builder: (context, state) {
          final id = state.pathParameters['callId'] ?? '';
          return ActiveCallScreen(callId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.newGroup,
        builder: (context, state) => const NewGroupScreen(),
      ),
    ],
  );
}