import 'dart:convert';

Map<String, dynamic> stringKeyedMap(dynamic data) {
  if (data is Map) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

String safeJsonString(dynamic data) {
  try {
    return const JsonEncoder.withIndent('  ').convert(data);
  } catch (_) {
    return data?.toString() ?? '';
  }
}
