import 'package:flutter/material.dart';
import 'package:koopcare/core/app_colors.dart';
import 'package:koopcare/features/faq/data/models/faq_item.dart';

class FaqTile extends StatefulWidget {
  final FaqItem item;
  final bool isOpen;
  final bool isLast;
  final VoidCallback onTap;

  const FaqTile({
    super.key,
    required this.item,
    required this.isOpen,
    required this.isLast,
    required this.onTap,
  });

  @override
  State<FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<FaqTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOutCubic,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic),
    );

    if (widget.isOpen) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant FaqTile old) {
    super.didUpdateWidget(old);
    if (widget.isOpen != old.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: widget.isOpen
                ? const Color(0xFFF0F5E8)
                : kPutih,
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: widget.isOpen
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: widget.isOpen
                          ? kHijauTua
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                RotationTransition(
                  turns: _rotateAnim,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: widget.isOpen
                        ? kHijauTua
                        : const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizeTransition(
          sizeFactor: _expandAnim,
          axisAlignment: -1,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              width: double.infinity,
              color: kPutih,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.item.answer,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),

        if (!widget.isLast)
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}
