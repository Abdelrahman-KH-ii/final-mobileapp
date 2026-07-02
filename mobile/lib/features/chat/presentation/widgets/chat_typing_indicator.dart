import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';

class ChatTypingIndicator extends StatelessWidget {
  final bool isDark;

  const ChatTypingIndicator({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        isDark ? Pallete.darkSurfaceVariant : const Color(0xFFF3F4F0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Pallete.primary.withAlpha(40)
                      : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.eco_rounded,
              size: 18,
              color: isDark ? Pallete.chartGreen : Pallete.primary,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ChatAnimatedDots(isDark: isDark),
          ),
        ],
      ),
    );
  }
}

class ChatAnimatedDots extends StatefulWidget {
  final bool isDark;

  const ChatAnimatedDots({super.key, required this.isDark});

  @override
  State<ChatAnimatedDots> createState() => _ChatAnimatedDotsState();
}

class _ChatAnimatedDotsState extends State<ChatAnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Row(
        children: List.generate(3, (i) {
          final delay = i * 0.2;
          final t = ((_ctrl.value + delay) % 1.0);
          final scale = 0.6 + 0.4 * (t < 0.5 ? t * 2 : (1 - t) * 2);
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Transform.scale(
              scale: scale.clamp(0.0, 1.0),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      widget.isDark
                          ? Pallete.darkTextTertiary
                          : Pallete.textHint.withAlpha(150),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
