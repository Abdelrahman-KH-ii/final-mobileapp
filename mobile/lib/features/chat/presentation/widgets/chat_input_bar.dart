import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final TextEditingController textController;
  final FocusNode focusNode;
  final ValueChanged<String> onSend;
  final bool isSending;

  const ChatInputBar({
    super.key,
    required this.isDark,
    required this.l,
    required this.textController,
    required this.focusNode,
    required this.onSend,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    final barBg = isDark ? Pallete.darkBackground : Pallete.background;
    final fieldBg = isDark ? const Color(0xFF1F222B) : Colors.white;
    final borderClr = isDark ? const Color(0xFF2E313D) : const Color(0xFFDDDEE2);
    final textClr = isDark ? Pallete.darkTextPrimary : Pallete.textPrimary;
    final hintClr = isDark ? Pallete.darkTextTertiary : const Color(0xFF8A8F9E);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      color: barBg,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              style: AppFonts.font(fontSize: 15, color: textClr),
              cursorColor: isDark ? Pallete.chartGreen : Pallete.primary,
              decoration: InputDecoration(
                hintText: l.tr('ask_anything'),
                hintStyle: AppFonts.font(fontSize: 15, color: hintClr),
                filled: true,
                fillColor: fieldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: borderClr),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: borderClr, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: isDark ? Pallete.chartGreen : Pallete.primary,
                    width: 1.6,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: isDark ? Pallete.darkTextTertiary : const Color(0xFF8A8F9E),
                    size: 22,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 46,
                  minHeight: 46,
                ),
                isDense: true,
              ),
              enabled: !isSending,
              onSubmitted: isSending ? null : onSend,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isSending ? null : () => onSend(textController.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isDark ? Pallete.chartGreen : Pallete.primary)
                    .withAlpha(isSending ? 140 : 255),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 24 : 16),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
