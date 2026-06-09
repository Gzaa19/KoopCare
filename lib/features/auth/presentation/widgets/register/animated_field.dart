import 'package:flutter/material.dart';

class AnimatedField extends StatelessWidget {
  final Animation<Offset> slide;
  final Animation<double> fade;
  final Widget child;

  const AnimatedField({
    super.key,
    required this.slide,
    required this.fade,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
