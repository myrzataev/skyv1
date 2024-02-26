import 'package:Skynet/views/more/web.dart';
import 'package:Skynet/views/start.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Skynet/login_screen.dart';
import 'package:Skynet/views/home/home_view.dart';
import 'package:Skynet/views/home/support.dart';
import 'package:Skynet/views/payment/payhistory.dart';
import 'package:Skynet/views/payment/payment.dart';
import 'package:Skynet/views/more/more.dart';
import 'package:Skynet/views/news/settings_view.dart';
import 'package:Skynet/views/news/sub_setting_view.dart';
import 'package:Skynet/views/wrapper/main_wrapper.dart';



class AppNavigation {
  AppNavigation._();

  static String initial = "/home";

  // Private navigators
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _shellNavigatorews =
      GlobalKey<NavigatorState>(debugLabel: 'shellNews');
  static final _shellNavigatorAdd =
      GlobalKey<NavigatorState>(debugLabel: 'shellAdd');


  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: initial,
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    routes: [
      /// MainWrapper
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(
            navigationShell: navigationShell,
          );
        },
        branches: <StatefulShellBranch>[
          /// Brach Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: <RouteBase>[
              GoRoute(
                path: "/home",
                name: "Главная",
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeView(),
                routes: [

                  GoRoute(
                    path: 'payhistory',
                    name: 'payhistory',
                    pageBuilder: (context, state) => CustomTransitionPage<void>(
                      key: state.pageKey,
                      child: const PaymentHistoryScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                    ),
                  ),
                  GoRoute(
                    path: 'payment',
                    name: 'payment',
                    pageBuilder: (context, state) => CustomTransitionPage<void>(
                      key: state.pageKey,
                      child: const PaymentScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                    ),
                  ),
                  GoRoute(
                    path: 'chat',
                    name: 'chat',
                    pageBuilder: (context, state) => CustomTransitionPage<void>(
                      key: state.pageKey,
                      child:  ChatScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// Brach Setting
          StatefulShellBranch(
            navigatorKey: _shellNavigatorews,
            routes: <RouteBase>[
              GoRoute(
                path: "/news",
                name: "новости",
                builder: (BuildContext context, GoRouterState state) =>
                     NewsView(),
                routes: [
                  // GoRoute(
                  //   path: "subSetting",
                  //   name: "subSetting",
                  //   pageBuilder: (context, state) {
                  //     return CustomTransitionPage<void>(
                  //       key: state.pageKey,
                  //       child: const SubSettingsView(),
                  //       transitionsBuilder: (
                  //         context,
                  //         animation,
                  //         secondaryAnimation,
                  //         child,
                  //       ) =>
                  //           FadeTransition(opacity: animation, child: child),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ],
          ),


          StatefulShellBranch(
            navigatorKey: _shellNavigatorAdd,
            routes: <RouteBase>[
              GoRoute(
                path: "/addd",
                name: "sdsdsd",
                builder: (BuildContext context, GoRouterState state) =>
                const SettingScreen(),

              ),
            ],
          ),

        ],
      ),

      /// Player
      // GoRoute(
      //   parentNavigatorKey: _rootNavigatorKey,
      //   path: '/payhistory',
      //   name: "payhistory",
      //   builder: (context, state) => PaymentHistoryScreen(
      //     key: state.pageKey,
      //   ),
      // ),
      // GoRoute(
      //   parentNavigatorKey: _rootNavigatorKey,
      //   path: '/payment',
      //   name: "payment",
      //   builder: (context, state) => PaymentScreen(
      //     key: state.pageKey,
      //   ),
      // ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/login',
        name: "login",
        builder: (context, state) => LoginScreen(
          key: state.pageKey,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/start',
        name: "start",
        builder: (context, state) => Start(
          key: state.pageKey,
        ),
      )
    ],
  );
}
