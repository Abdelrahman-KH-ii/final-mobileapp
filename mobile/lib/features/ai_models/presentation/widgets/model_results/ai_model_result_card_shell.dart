import 'package:flutter/material.dart';
import 'package:farmtec/core/themes/app_fonts.dart';

class AiModelResultCardShell extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color cardColor;
  final Color textColor;
  final Color accentGreen;
  final Color topAccentColor;
  final IconData icon;
  final Color iconColor;
  final Color? borderColor;
  final Gradient? backgroundGradient;
  final BorderRadius? borderRadius;

  const AiModelResultCardShell({
    super.key,
    required this.title,
    required this.children,
    required this.cardColor,
    required this.textColor,
    required this.accentGreen,
    this.topAccentColor = Colors.green,
    this.icon = Icons.insights_rounded,
    this.iconColor = Colors.green,
    this.borderColor,
    this.backgroundGradient,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final effectiveBorderColor = borderColor ?? accentGreen.withAlpha(60);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        gradient: backgroundGradient,
        borderRadius: effectiveBorderRadius,
        border: Border.all(color: effectiveBorderColor),
        boxShadow: [
          BoxShadow(
            color: accentGreen.withAlpha(12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppFonts.font(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...children,
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AiModelResultSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color textColor;
  final Color accentGreen;
  final Color sectionColor;
  final Color sectionBorderColor;

  const AiModelResultSection({
    super.key,
    required this.title,
    required this.children,
    required this.textColor,
    required this.accentGreen,
    this.sectionColor = Colors.white,
    this.sectionBorderColor = const Color(0xFFE6F2E9),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: sectionColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sectionBorderColor),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.font(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accentGreen,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class AiModelResultField extends StatelessWidget {
  final String label;
  final String value;
  final Color bulletColor;
  final Color textColor;

  const AiModelResultField({
    super.key,
    required this.label,
    required this.value,
    required this.bulletColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: bulletColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: AppFonts.font(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppFonts.font(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
