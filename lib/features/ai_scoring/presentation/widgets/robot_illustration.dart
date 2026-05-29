import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

/// Decorative robot shown on the processing page while the ML API resolves.
///
/// Owns its own spin animation; the parent supplies the bounce animation via
/// [bounceAnimation] so the whole illustration can hop in sync.
class RobotIllustration extends StatefulWidget {
  final Animation<double> bounceAnimation;

  const RobotIllustration({super.key, required this.bounceAnimation});

  @override
  State<RobotIllustration> createState() => _RobotIllustrationState();
}

class _RobotIllustrationState extends State<RobotIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.bounceAnimation,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, widget.bounceAnimation.value),
        child: child,
      ),
      child: SizedBox(
        width: 200,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                width: 90,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCCCCCC), width: 2),
                ),
              ),
            ),
            Positioned(
              top: 10,
              child: Container(
                width: 80,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCCCCCC), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _eye(),
                        const SizedBox(width: 14),
                        _eye(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 30,
                      height: 6,
                      decoration: BoxDecoration(
                        color: kHijauTua,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kHijauTua,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 12,
                    color: const Color(0xFFCCCCCC),
                  ),
                ],
              ),
            ),
            Positioned(bottom: 20, left: 10, child: _arm()),
            Positioned(bottom: 20, right: 10, child: _arm()),
            Positioned(
              top: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _spinCtrl,
                builder: (_, _) => Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(_spinCtrl.value * math.pi * 2),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5C542),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        r'$',
                        style: TextStyle(
                          color: kPutih,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 10,
              right: 16,
              child: Icon(
                Icons.settings_outlined,
                color: Color(0xFF888888),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eye() => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: kHijauTua,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF333333), width: 1),
        ),
      );

  Widget _arm() => Container(
        width: 16,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
        ),
      );
}
