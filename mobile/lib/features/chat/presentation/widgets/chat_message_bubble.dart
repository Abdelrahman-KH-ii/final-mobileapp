import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/chat/data/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final displayText = l.convertNumbers(l.trOr(message.text, message.text));
    final isUser = message.sender == ChatSender.user;

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 48),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Pallete.primary,
                  borderRadius: BorderRadius.circular(18).copyWith(
                    bottomRight: const Radius.circular(4),
                  ),
                ),
                child: Text(
                  displayText,
                  style: AppFonts.font(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bubbleColor =
        isDark ? Pallete.darkSurfaceVariant : const Color(0xFFF3F4F0);
    final nameColor =
        isDark ? Pallete.darkTextSecondary : Pallete.textSecondary;
    final textClr = isDark ? Pallete.darkTextPrimary : Pallete.textPrimary;

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
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.tr('farmbrain_ai'),
                  style: AppFonts.font(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: nameColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: MarkdownBody(
                    data: displayText,
                    selectable: false,
                    styleSheet: MarkdownStyleSheet(
                      p: AppFonts.font(
                        fontSize: 14,
                        color: textClr,
                        height: 1.6,
                      ),
                      strong: AppFonts.font(
                        fontSize: 14,
                        color: textClr,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                      ),
                      em: AppFonts.font(
                        fontSize: 14,
                        color: textClr,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                      code: AppFonts.font(
                        fontSize: 14,
                        color: textClr,
                        backgroundColor: isDark ? const Color(0xFF1E1F28) : const Color(0xFFEFEFF2),
                        height: 1.6,
                      ),
                    ),
                    softLineBreak: true,
                    fitContent: true,
                    imageBuilder: (uri, title, alt) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
