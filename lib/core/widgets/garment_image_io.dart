import 'dart:io';

import 'package:flutter/material.dart';

Widget garmentImage(
  String source, {
  BoxFit fit = BoxFit.cover,
  required Widget Function() fallback,
}) =>
    Image.file(
      File(source),
      fit: fit,
      errorBuilder: (_, __, ___) => fallback(),
    );
