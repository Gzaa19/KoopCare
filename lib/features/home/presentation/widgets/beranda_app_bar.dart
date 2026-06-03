import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_state.dart';

/// Top app bar row for the Beranda page.
/// Shows user avatar, greeting + name, and a notification bell with badge.
class BerandaAppBar extends StatelessWidget {
  final AuthUser? user;
  final String greeting;

  const BerandaAppBar({
    super.key,
    required this.user,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user?.name ?? '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kPutih,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8F0D8), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: kHijauTua,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Greeting + name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, notifState) {
              return GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, RouteNames.notification),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: kPutih,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF444444),
                        size: 22,
                      ),
                    ),
                    if (notifState.unreadCount > 0)
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kPutih, width: 1.5),
                          ),
                          child: Text(
                            notifState.unreadCount > 99
                                ? '99+'
                                : '${notifState.unreadCount}',
                            style: const TextStyle(
                              color: kPutih,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Decorative gold chip shown inside the balance card.
class GoldChip extends StatelessWidget {
  const GoldChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GridPaper(
              color: Colors.black.withValues(alpha: 0.12),
              divisions: 2,
              subdivisions: 1,
              child: const SizedBox.shrink(),
            ),
          ),
          Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
