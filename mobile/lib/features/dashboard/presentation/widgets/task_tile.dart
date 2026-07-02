import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/dashboard_card_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskTile extends StatefulWidget {
  final String title;
  final String schedule;
  final bool initialCompleted;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subColor;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.title,
    required this.schedule,
    required this.initialCompleted,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
    required this.onDelete,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.initialCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? const Color(0xFF22C55E) : Pallete.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: dashboardCardDecoration(widget.isDark, widget.cardColor),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => isCompleted = !isCompleted),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppFonts.font(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isCompleted ? widget.subColor : widget.textColor,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: widget.subColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.schedule,
                      style: AppFonts.font(
                        fontSize: 11,
                        color: widget.subColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: widget.subColor,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
