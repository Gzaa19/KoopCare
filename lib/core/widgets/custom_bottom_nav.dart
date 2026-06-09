import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'activeIcon': Icons.home_rounded,
        'inactiveIcon': Icons.home_outlined,
        'label': 'Beranda',
      },
      {
        'activeIcon': Icons.account_balance_wallet_rounded,
        'inactiveIcon': Icons.account_balance_wallet_outlined,
        'label': 'Simpanan',
      },
      {
        'activeIcon': Icons.receipt_long_rounded,
        'inactiveIcon': Icons.receipt_long_outlined,
        'label': 'Cicilan',
      },
      {
        'activeIcon': Icons.person_rounded,
        'inactiveIcon': Icons.person_outline_rounded,
        'label': 'Akun',
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth > 600 ? 480.0 : screenWidth - 32;

    return Center(
      heightFactor: 1.0,
      child: Container(
        width: barWidth,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: kPutih.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D2E14).withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: SizedBox(
              height: 72,
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    alignment: Alignment(
                      -1.0 + (selectedIndex * 2.0 / (items.length - 1)),
                      0.0,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 1.0 / items.length,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: kHijauTua,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: kHijauTua.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(items.length, (i) {
                      final active = i == selectedIndex;
                      final item = items[i];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(i),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  active ? FontWeight.bold : FontWeight.w500,
                              color: active
                                  ? kPutih
                                  : kHijauTua.withValues(alpha: 0.6),
                            ),
                            child: IconTheme(
                              data: IconThemeData(
                                color: active
                                    ? kPutih
                                    : kHijauTua.withValues(alpha: 0.5),
                                size: 22,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (child, animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                    child: Icon(
                                      active
                                          ? (item['activeIcon'] as IconData)
                                          : (item['inactiveIcon'] as IconData),
                                      key: ValueKey<bool>(active),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item['label'] as String),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
