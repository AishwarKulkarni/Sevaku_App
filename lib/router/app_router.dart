import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sevaku/features/auth/screens/get_started_screen.dart';
import 'package:sevaku/features/auth/screens/login_screen.dart';
import 'package:sevaku/features/auth/screens/register_screen.dart';
import 'package:sevaku/features/auth/screens/forgot_password_screen.dart';
import 'package:sevaku/features/home/screens/customer_home_screen.dart';
import 'package:sevaku/features/bookings/screens/bookings_list_screen.dart';
import 'package:sevaku/features/bookings/screens/booking_flow_screen.dart';
import 'package:sevaku/features/chat/screens/chat_list_screen.dart';
import 'package:sevaku/features/chat/screens/chat_room_screen.dart';
import 'package:sevaku/features/profile/screens/edit_profile_screen.dart';
import 'package:sevaku/features/profile/screens/customer_profile_screen.dart';
import 'package:sevaku/features/workers/screens/worker_list_screen.dart';
import 'package:sevaku/features/workers/screens/worker_profile_screen.dart';
import 'package:sevaku/features/dashboard/screens/worker_dashboard_screen.dart';
import 'package:sevaku/features/navigation/customer_shell.dart';
import 'package:sevaku/features/navigation/worker_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevaku/features/auth/providers/auth_provider.dart';
import 'package:sevaku/core/constants/app_constants.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        // Only notify GoRouter to re-evaluate redirect if the auth status changes
        if (previous?.status != next.status) {
          notifyListeners();
        }
      },
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      final isAuth = authState.status == AuthStatus.authenticated;
      final isInit = authState.status == AuthStatus.initial;
      final isGoingToAuth = state.uri.path == '/' ||
          state.uri.path == '/login' ||
          state.uri.path == '/register' ||
          state.uri.path == '/forgot-password';

      if (isInit) return null;

      if (!isAuth && !isGoingToAuth) {
        return '/login';
      }

      if (isAuth && isGoingToAuth) {
        final isCustomer = authState.user?.role == AppConstants.roleCustomer;
        return isCustomer ? '/customer' : '/worker';
      }

      return null;
    },
    routes: [
    // Get Started
    GoRoute(
      path: '/',
      builder: (context, state) => const GetStartedScreen(),
    ),
    // Auth
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Customer Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CustomerShell(navigationShell: navigationShell);
      },
      branches: [
        // Home Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer',
              builder: (context, state) => const CustomerHomeScreen(),
            ),
          ],
        ),
        // Bookings Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer/bookings',
              builder: (context, state) => const BookingsListScreen(),
            ),
          ],
        ),
        // Chat Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer/chats',
              builder: (context, state) => const ChatListScreen(),
            ),
          ],
        ),
        // Profile Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer/profile',
              builder: (context, state) => const CustomerProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Worker Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return WorkerShell(navigationShell: navigationShell);
      },
      branches: [
        // Dashboard Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/worker',
              builder: (context, state) => const WorkerDashboardScreen(),
            ),
          ],
        ),
        // Jobs Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/worker/jobs',
              builder: (context, state) => const BookingsListScreen(),
            ),
          ],
        ),
        // Chat Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/worker/chats',
              builder: (context, state) => const ChatListScreen(),
            ),
          ],
        ),
        // Profile Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/worker/profile',
              builder: (context, state) => const CustomerProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Shared routes (push in front of shell)
    GoRoute(
      path: '/customer/workers/:category',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.pathParameters['category'];
        return WorkerListScreen(category: category);
      },
    ),
    GoRoute(
      path: '/customer/worker/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return WorkerProfileScreen(workerId: id);
      },
    ),
    GoRoute(
      path: '/customer/booking/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final workerId = state.uri.queryParameters['workerId'];
        return BookingFlowScreen(workerId: workerId);
      },
    ),
    GoRoute(
      path: '/customer/chat/:chatId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        return ChatRoomScreen(chatId: chatId);
      },
    ),
    // Shared chat room — works for both customer and worker roles
    GoRoute(
      path: '/chat/:chatId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        return ChatRoomScreen(chatId: chatId);
      },
    ),
    GoRoute(
      path: '/customer/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return const WorkerListScreen(category: 'all');
      },
    ),
    GoRoute(
      path: '/edit-profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return const EditProfileScreen();
      },
    ),
  ],
);
});
