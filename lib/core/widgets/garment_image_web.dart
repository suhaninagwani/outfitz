import 'dart:convert';

import 'package:flutter/material.dart';

Widget garmentImage(
  String source, {
  BoxFit fit = BoxFit.cover,
  required Widget Function() fallback,
}) {
  try {
    final comma = source.indexOf(',');
    final payload = comma == -1 ? source : source.substring(comma + 1);
    return Image.memory(
      base64Decode(payload),
      fit: fit,
      errorBuilder: (_, __, ___) => fallback(),
    );
  } on FormatException {
    return fallback();
  }
}
