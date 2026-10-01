import 'package:flutter/material.dart';
import '../../../core/mock.dart';
import '../../../core/widgets.dart';
import '../domain/clothing_item.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});
  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  Category? filter;
  @override
  Widget build(BuildContext context) {
    final items = wardrobe.where((i) => filter == null || i.category == filter).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('My wardrobe', style: Theme.of(context).textTheme.headlineSmall),
            Pill('${wardrobe.length} items'),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const Text('All'), selected: filter == null,
                onSelected: (_) => setState(() => filter = null)),
            for (final c in Category.values)
              ChoiceChip(label: Text(c.name), selected: filter == c,
                  onSelected: (_) => setState(() => filter = c)),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
              children: [
                for (final i in items)
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    EmojiTile(i.emoji, size: 90),
                    const SizedBox(height: 6),
                    Text(i.name, style: Theme.of(context).textTheme.bodySmall),
                  ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
