import 'package:flutter/material.dart';

BoxDecoration dashboardCardDecoration(bool isDark, Color cardColor) =>
    BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(isDark ? 25 : 12),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );
