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
import 'core/shell/main_shell.dart';
import 'core/shell/presentation/cubit/navigation_cubit.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'features/notification/presentation/bloc/notification_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  await initializeDateFormatting('id_ID', null);

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
          create: (_) =>
              getIt<AuthBloc>()..add(const AuthUserRestoreRequested()),
        ),
        BlocProvider<NotificationBloc>.value(
          value: getIt<NotificationBloc>(),
        ),
        BlocProvider<NavigationCubit>(
          create: (_) => NavigationCubit(),
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
          if (authState.status == AuthStatus.unauthenticated) {
            return const LoginPage();
          }

          if (authState.status == AuthStatus.authenticated) {
            return const MainShell();
          }

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
