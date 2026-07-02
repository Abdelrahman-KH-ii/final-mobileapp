import 'package:flutter/material.dart';

enum AIModelKind { standard, vision }

class AIModelDefinition {
  final String name;
  final String desc;
  final String apiUrl;
  final IconData icon;
  final String backgroundImage;
  final List<AIModelFieldDefinition> fields;
  final AIModelKind kind;
  final bool useBackend;
  final String httpMethod;

  const AIModelDefinition({
    required this.name,
    required this.desc,
    required this.icon,
    required this.backgroundImage,
    required this.apiUrl,
    required this.fields,
    this.kind = AIModelKind.standard,
    this.useBackend = true,
    this.httpMethod = 'POST',
  });

  bool get isVisionModel => kind == AIModelKind.vision;
}

class AIModelFieldDefinition {
  final String key;
  final String label;
  final String hint;
  final TextInputType type;

  const AIModelFieldDefinition({
    required this.key,
    required this.label,
    required this.hint,
    required this.type,
  });
}
