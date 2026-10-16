import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/garment_tile.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/widgets/panels.dart';
import '../domain/wardrobe_item.dart';
import 'insights_page.dart';
import 'item_detail_page.dart';

class WardrobePage extends ConsumerStatefulWidget {
  const WardrobePage({super.key});

  @override
  ConsumerState<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends ConsumerState<WardrobePage> {
  final _search = TextEditingController();
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(wardrobeProvider);
    final filter = ref.watch(categoryFilterProvider);
    final visible = ref.watch(visibleWardrobeProvider);
    final items = _query.isEmpty
        ? visible
        : visible
            .where((i) =>
                i.name.toLowerCase().contains(_query) ||
                i.colourName.toLowerCase().contains(_query) ||
                i.category.label.toLowerCase().contains(_query))
            .toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MicroLabel(
                        _query.isNotEmpty || filter != null
                            ? '${items.length} of ${all.length} pieces'
                            : '${all.length} pieces',
                        color: AppColors.wine,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'My wardrobe',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                ),
                _IconAction(
                  icon: _searching ? Icons.close : Icons.search,
                  onTap: () => setState(() {
                    _searching = !_searching;
                    if (!_searching) {
                      _search.clear();
                      _query = '';
                    }
                  }),
                ),
                const SizedBox(width: 8),
                _IconAction(
                  icon: Icons.bar_chart,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InsightsPage()),
                  ),
                ),
              ],
            ),
          ),
          if (_searching)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: TextField(
                controller: _search,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                decoration: const InputDecoration(hintText: 'Search by name or colour'),
              ),
            ),
          const SizedBox(height: 18),

          // Category rail — counts included so an empty category is obvious.
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              children: [
                OutfitzChip(
                  label: 'All ${all.length}',
                  selected: filter == null,
                  onTap: () => ref.read(categoryFilterProvider.notifier).select(null),
                ),
                for (final c in GarmentCategory.values) ...[
                  const SizedBox(width: 8),
                  OutfitzChip(
                    label: '${c.label} ${all.where((i) => i.category == c).length}',
                    selected: filter == c,
                    onTap: () =>
                        ref.read(categoryFilterProvider.notifier).select(filter == c ? null : c),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          Expanded(
            child: items.isEmpty
                ? _EmptyState(
                    filter: filter,
                    filtered: _query.isNotEmpty || filter != null,
                    onAdd: () => startAddFlow(context, ref),
                  )
                : LayoutBuilder(
                    builder: (context, c) {
                      const gap = 16.0;
                      final tileWidth = (c.maxWidth - 44 - gap) / 2;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 120),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: gap,
                          mainAxisSpacing: 24,
                          mainAxisExtent: tileWidth + 62,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) => ItemCard(
                          item: items[i],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ItemDetailPage(itemId: items[i].id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line),
          ),
          child: Icon(icon, size: 18),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.filter,
    required this.filtered,
    required this.onAdd,
  });

  final GarmentCategory? filter;
  final bool filtered;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 90),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Ornament(kind: OrnamentKind.circle, size: 54, stroke: 1),
              const SizedBox(height: 22),
              Text(
                filtered ? 'Nothing here yet.' : 'Your wardrobe is empty.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                filter == null
                    ? 'Photograph your first piece and Outfitz starts dressing you '
                        'for the weather.'
                    : 'You have no ${filter!.label.toLowerCase()} yet. Add one and it '
                        'joins the rotation.',
                textAlign: TextAlign.center,
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: FilledButton(
                  onPressed: onAdd,
                  child: Text(
                    filter == null ? 'Add a piece' : 'Add a ${filter!.singular.toLowerCase()}',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
