import 'package:flutter/material.dart';

BoxDecoration myFarmCardDecoration(bool isDark, Color cardColor) =>
    BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(isDark ? 25 : 10),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
