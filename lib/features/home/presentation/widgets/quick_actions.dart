import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/domain/entities/auth_user.dart';

/// Grid of 4 quick action shortcuts on the home screen.
class QuickActions extends StatelessWidget {
  final AuthUser? user;

  /// Callback to switch the main shell tab (e.g. tab index 1 = Simpanan).
  final void Function(int)? onSwitchTab;

  const QuickActions({
    super.key,
    required this.user,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.savings_outlined, 'label': 'Simpan\nDana'},
      {'icon': Icons.description_outlined, 'label': 'Ajukan\nPinjaman'},
      {'icon': Icons.swap_horiz_rounded, 'label': 'Transfer'},
      {'icon': Icons.history_rounded, 'label': 'Riwayat'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions.map((a) {
        final label = a['label'] as String;
        return _QuickAction(
          icon: a['icon'] as IconData,
          label: label,
          onTap: switch (label) {
            'Simpan\nDana' => () => onSwitchTab?.call(1),
            'Ajukan\nPinjaman' => () => guardVerified(
                  context,
                  status: user?.status,
                  action: () => Navigator.pushNamed(context, RouteNames.pengajuan),
                ),
            'Transfer' => () => guardVerified(
                  context,
                  status: user?.status,
                  action: () => Navigator.pushNamed(context, RouteNames.transfer),
                ),
            _ => null,
          },
        );
      }).toList(),
    );
  }
}

/// Single tappable action button with icon + label.
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kPutih,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE8F0D8).withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: kHijauTua, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
