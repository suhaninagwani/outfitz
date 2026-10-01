import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class Pill extends StatelessWidget {
  final String text;
  const Pill(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppColors.butter, borderRadius: BorderRadius.circular(99)),
        child: Text(text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
      );
}

class EmojiTile extends StatelessWidget {
  final String emoji;
  final double size;
  const EmojiTile(this.emoji, {this.size = 64, super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(18)),
        child: Text(emoji, style: TextStyle(fontSize: size * .5)),
      );
}
