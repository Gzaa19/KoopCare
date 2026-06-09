import 'package:flutter/material.dart';

class CustomNumpad extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback? onDone;

  const CustomNumpad({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _numpadRow(['1', '2', '3']),
        const SizedBox(height: 10),
        _numpadRow(['4', '5', '6']),
        const SizedBox(height: 10),
        _numpadRow(['7', '8', '9']),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 72,
              height: 52,
              child: onDone != null
                  ? InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onDone,
                      child: const Center(
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            _numpadKey('0'),
            SizedBox(
              width: 72,
              height: 52,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onDelete,
                child: const Icon(
                  Icons.backspace_outlined,
                  color: Color(0xFF555555),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _numpadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _numpadKey(d)).toList(),
    );
  }

  Widget _numpadKey(String digit) {
    return SizedBox(
      width: 72,
      height: 52,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onKeyPress(digit),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
