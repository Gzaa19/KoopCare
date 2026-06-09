import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class RobotIllustration extends StatefulWidget {
  final Animation<double> bounceAnimation;

  const RobotIllustration({super.key, required this.bounceAnimation});

  @override
  State<RobotIllustration> createState() => _RobotIllustrationState();
}

class _RobotIllustrationState extends State<RobotIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _localCtrl;
  late final Animation<double> _armFloat;
  late final Animation<double> _eyeBlink;
  late final AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _localCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _armFloat = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _localCtrl, curve: Curves.easeInOutQuad),
    );

    _eyeBlink = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.1), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 1.0), weight: 5),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 10),
    ]).animate(_localCtrl);

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _localCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.bounceAnimation.value),
          child: child,
        );
      },
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 8,
              child: AnimatedBuilder(
                animation: widget.bounceAnimation,
                builder: (context, _) {
                  final progress = (widget.bounceAnimation.value + 12) / 12;
                  final width = 90 - (progress * 15);
                  final opacity = 0.15 - (progress * 0.08);
                  return Container(
                    width: width,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: opacity.clamp(0.0, 1.0)),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: opacity.clamp(0.0, 1.0)),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Positioned(
              left: 18,
              top: 108,
              child: AnimatedBuilder(
                animation: _armFloat,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, _armFloat.value),
                    child: _buildCyberArm(leftSide: true),
                  );
                },
              ),
            ),

            Positioned(
              right: 18,
              top: 108,
              child: AnimatedBuilder(
                animation: _armFloat,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, -_armFloat.value),
                    child: _buildCyberArm(leftSide: false),
                  );
                },
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8DE85A).withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8DE85A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 3,
                  height: 14,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8DE85A), Color(0xFFB5C59C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                Container(
                  width: 110,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE6EBD6), Color(0xFFC7D0B4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kHijauTua.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    child: Container(
                      width: 84,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF14240B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: kHijauMuda.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGlowingEye(),
                          const SizedBox(width: 16),
                          _buildGlowingEye(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                Container(
                  width: 24,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9CA988),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 2),

                Container(
                  width: 124,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE6EBD6), Color(0xFFBDC7A8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kHijauTua.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1C06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF8DE85A).withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.query_stats_rounded,
                            color: Color(0xFF8DE85A),
                            size: 16,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return AnimatedBuilder(
                                animation: _localCtrl,
                                builder: (context, _) {
                                  final modifier = math.sin(_localCtrl.value * math.pi * 2 + index);
                                  final height = (10 + (modifier * 4)).clamp(4.0, 16.0);
                                  return Container(
                                    width: 3.5,
                                    height: height,
                                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8DE85A),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              top: 52,
              right: 32,
              child: AnimatedBuilder(
                animation: _spinCtrl,
                builder: (context, child) {
                  final x = math.sin(_spinCtrl.value * math.pi * 2) * 15;
                  final y = math.cos(_spinCtrl.value * math.pi * 2) * 8;
                  final s = 0.8 + math.sin(_spinCtrl.value * math.pi * 2) * 0.2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.translationValues(x, y, 0.0)
                      ..multiply(Matrix4.diagonal3Values(s, s, 1.0)),
                    child: child,
                  );
                },
                child: _buildRevolvingCoin(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingEye() {
    return AnimatedBuilder(
      animation: _eyeBlink,
      builder: (context, _) {
        return Transform.scale(
          scaleY: _eyeBlink.value,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF8DE85A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8DE85A).withValues(alpha: 0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCyberArm({required bool leftSide}) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF8DE85A),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 12,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFC7D0B4), Color(0xFF9CA988)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              topLeft: leftSide ? const Radius.circular(8) : Radius.zero,
              bottomLeft: const Radius.circular(8),
              topRight: leftSide ? Radius.zero : const Radius.circular(8),
              bottomRight: const Radius.circular(8),
            ),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRevolvingCoin() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDD835), Color(0xFFF57F17)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF57F17).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '\$',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
