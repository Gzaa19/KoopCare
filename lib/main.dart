import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_colors.dart';
import 'core/di/service_locator.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/main_shell.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'features/notification/presentation/bloc/notification_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  // Initialize locale data for intl (DateFormat, NumberFormat with 'id_ID')
  await initializeDateFormatting('id_ID', null);

  // Initialize local notification plugin (request permissions etc.).
  await getIt<NotificationService>().init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          // Single AuthBloc instance for the whole app lifetime.
          create: (_) =>
              getIt<AuthBloc>()..add(const AuthUserRestoreRequested()),
        ),
        BlocProvider<NotificationBloc>.value(
          // Singleton — polling state persists across the whole app session.
          value: getIt<NotificationBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Decides which page to show on startup.
///
/// Checks the JWT token in SharedPreferences:
/// - Token present → [MainShell] (home)
/// - No token      → [LoginPage]
///
/// After routing to MainShell, [AuthProfileRefreshRequested] is fired so the
/// balance shown on the beranda is always up-to-date.
///
/// Also starts notification polling when authenticated and stops it on logout.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        final notifBloc = context.read<NotificationBloc>();
        if (authState.status == AuthStatus.authenticated) {
          notifBloc.add(const NotificationPollingStarted());
        } else if (authState.status == AuthStatus.unauthenticated) {
          notifBloc.add(const NotificationPollingStopped());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // If the BLoC explicitly says "unauthenticated" (after logout),
          // go straight to LoginPage — no need for the FutureBuilder.
          if (authState.status == AuthStatus.unauthenticated) {
            return const LoginPage();
          }

          // If the BLoC already has an authenticated user (restored or logged in),
          // go straight to MainShell.
          if (authState.status == AuthStatus.authenticated) {
            return const MainShell();
          }

          // Initial / loading → check the persisted token once.
          return FutureBuilder<bool>(
            future: getIt<AuthRepository>().isLoggedIn(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  backgroundColor: kHijauTua,
                  body: Center(
                      child:
                          CircularProgressIndicator(color: Colors.white)),
                );
              }
              if (snapshot.data!) {
                // Fire a background profile refresh so balance is current.
                context
                    .read<AuthBloc>()
                    .add(const AuthProfileRefreshRequested());
                return const MainShell();
              }
              return const LoginPage();
            },
          );
        },
      ),
    );
  }
}
