import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/garment_tile.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/widgets/panels.dart';
import '../domain/wardrobe_item.dart';

/// Step 3: the tags. Auto-detected suggestions on top, the user's word is final.
class ConfirmItemPage extends ConsumerStatefulWidget {
  const ConfirmItemPage({
    required this.imageBytes,
    required this.detectedColour,
    this.existing,
    super.key,
  });

  final Uint8List imageBytes;
  final WardrobeColour detectedColour;

  /// Set when the user is editing an existing piece rather than adding one.
  final WardrobeItem? existing;

  @override
  ConsumerState<ConfirmItemPage> createState() => _ConfirmItemPageState();
}

class _ConfirmItemPageState extends ConsumerState<ConfirmItemPage> {
  late GarmentCategory _category;
  late int _colourHex;
  late int _warmthMin;
  late int _warmthMax;
  late Set<Mood> _moods;
  late final TextEditingController _name;

  bool _analysing = true;
  bool _saving = false;
  bool _warmthTouched = false;
  Timer? _analysis;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    // The detector only ever returns a colour; naming and warming the piece is
    // what the user is here for.
    _colourHex = existing?.colourHex ?? widget.detectedColour.hex;
    _category = existing?.category ?? GarmentCategory.tops;
    _moods = existing?.moods.isNotEmpty == true
        ? {...existing!.moods}
        : {Mood.elegant};
    final band = _defaultWarmth(_category);
    _warmthMin = existing?.warmthMin ?? band.$1;
    _warmthMax = existing?.warmthMax ?? band.$2;
    _name = TextEditingController(text: existing?.name ?? _suggestName());

    _analysis = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _analysing = false);
    });
  }

  @override
  void dispose() {
    _analysis?.cancel();
    _name.dispose();
    super.dispose();
  }

  String _suggestName() =>
      '${widget.detectedColour.name} ${_category.singular.toLowerCase()}';

  static (int, int) _defaultWarmth(GarmentCategory c) => switch (c) {
        GarmentCategory.tops => (16, 30),
        GarmentCategory.bottoms => (10, 28),
        GarmentCategory.layers => (5, 20),
        GarmentCategory.dresses => (16, 30),
        GarmentCategory.shoes => (5, 30),
        GarmentCategory.bags => (0, 45),
        GarmentCategory.accessories => (0, 45),
      };

  void _pickColour(WardrobeColour c) {
    setState(() {
      _colourHex = c.hex;
      if (!_isEdit) _name.text = _suggestName();
    });
  }

  void _pickCategory(GarmentCategory c) {
    setState(() {
      _category = c;
      if (!_warmthTouched) {
        final band = _defaultWarmth(c);
        _warmthMin = band.$1;
        _warmthMax = band.$2;
      }
      if (!_isEdit) _name.text = _suggestName();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final messenger = ScaffoldMessenger.of(context);
    final id = widget.existing?.id ??
        'item-${DateTime.now().microsecondsSinceEpoch.toString()}';

    try {
      var path = widget.existing?.imagePath;
      if (!_isEdit) {
        path = await ref.read(imageStoreProvider).savePng(widget.imageBytes, id);
      }

      final item = WardrobeItem(
        id: id,
        name: _name.text.trim().isEmpty ? _suggestName() : _name.text.trim(),
        category: _category,
        colourHex: _colourHex,
        warmthMin: _warmthMin,
        warmthMax: _warmthMax,
        moods: _moods.isEmpty ? {Mood.minimal} : _moods,
        imagePath: path,
        wornCount: widget.existing?.wornCount ?? 0,
        lastWorn: widget.existing?.lastWorn,
        addedAt: widget.existing?.addedAt ?? DateTime.now(),
      );

      await ref.read(wardrobeProvider.notifier).add(item);
      if (!mounted) return;

      ref.read(shellTabProvider.notifier).go(1);
      Navigator.of(context).popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        SnackBar(content: Text('${item.name} added to your wardrobe')),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final colour = WardrobeColour.byHex(_colourHex);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(_isEdit ? 'Edit tags' : 'Confirm the tags'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(34),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: const StepBar(step: 2, labels: ['source', 'crop', 'tags']),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
        children: [
          _Preview(
            imageBytes: widget.imageBytes,
            item: widget.existing,
            colour: Color(_colourHex),
            analysing: _analysing,
          ),
          const SizedBox(height: 22),

          Row(
            children: [
              Text(_analysing ? 'Reading the photo' : 'Auto-detected',
                  style: t.titleLarge),
              const SizedBox(width: 10),
              if (!_analysing)
                const MicroLabel('✨ inferred', color: AppColors.wine, spacing: 1.6),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _analysing
                ? 'Cropping the garment and sampling its colour…'
                : 'Outfitz guessed the colour from the pixels. Change anything that '
                    'looks wrong — your answer is what gets remembered.',
            style: AppText.bodyMuted,
          ),
          const SizedBox(height: 22),

          if (!_analysing) ...[
            const LabelledRule('name'),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'e.g. Wine knit top'),
            ),
            const SizedBox(height: 24),

            const LabelledRule('category'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in GarmentCategory.values)
                  OutfitzChip(
                    label: c.label,
                    selected: _category == c,
                    onTap: () => _pickCategory(c),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            LabelledRule(
              'colour',
              trailing: MicroLabel(colour?.name ?? 'custom', color: AppColors.wine),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in WardrobeColour.palette)
                  ColourDot(
                    colour: c.color,
                    size: 32,
                    selected: _colourHex == c.hex,
                    onTap: () => _pickColour(c),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            LabelledRule(
              'warmth',
              trailing: MicroLabel('$_warmthMin–$_warmthMax°C', color: AppColors.wine),
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.wine,
                inactiveTrackColor: AppColors.line,
                thumbColor: AppColors.wine,
                overlayColor: AppColors.wine.withValues(alpha: .1),
                trackHeight: 3,
                rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 9),
              ),
              child: RangeSlider(
                values: RangeValues(_warmthMin.toDouble(), _warmthMax.toDouble()),
                min: 0,
                max: 45,
                divisions: 45,
                labels: RangeLabels('$_warmthMin°', '$_warmthMax°'),
                onChanged: (v) => setState(() {
                  _warmthTouched = true;
                  _warmthMin = v.start.round();
                  _warmthMax = v.end.round();
                }),
              ),
            ),
            Text(
              'The comfortable outside temperature for this piece. This is what '
              'makes the suggestions weather-aware.',
              style: AppText.bodyMuted,
            ),
            const SizedBox(height: 24),

            const LabelledRule('how does it feel?'),
            const SizedBox(height: 12),
            MoodChips(
              selected: _moods,
              onToggle: (m) => setState(() {
                _moods.contains(m) ? _moods.remove(m) : _moods.add(m);
              }),
            ),
            const SizedBox(height: 30),

            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: AppColors.white,
                      ),
                    )
                  : Text(_isEdit ? 'Save changes' : 'Save to wardrobe'),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                _isEdit
                    ? 'Editing an existing piece keeps its wear history.'
                    : 'Nothing leaves your phone.',
                style: AppText.bodyMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.imageBytes,
    required this.item,
    required this.colour,
    required this.analysing,
  });

  final Uint8List imageBytes;
  final WardrobeItem? item;
  final Color colour;
  final bool analysing;

  @override
  Widget build(BuildContext context) {
    final tile = SizedBox(
      width: 150,
      height: 190,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Stage(imageBytes: imageBytes, item: item, colour: colour),
          if (analysing)
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.canvas.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(AppTheme.tile),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 1.6),
                ),
              ),
            ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tile,
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MicroLabel('the scan', color: AppColors.wine),
              const SizedBox(height: 10),
              Text('One piece,\nclean edges.', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colour,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.line),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MicroLabel(
                    analysing ? 'sampling…' : 'sampled',
                    spacing: 1.4,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The image area of the preview: a saved photo, freshly cropped pixels, or —
/// when editing a seeded piece — the colour block.
class _Stage extends StatelessWidget {
  const _Stage({required this.imageBytes, required this.item, required this.colour});

  final Uint8List imageBytes;
  final WardrobeItem? item;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final path = item?.imagePath;
    if (path != null && path.isNotEmpty) {
      return GarmentTile(item: item!, size: 190, radius: AppTheme.tile);
    }
    if (imageBytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.tile),
        child: Image.memory(imageBytes, fit: BoxFit.cover),
      );
    }
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(AppTheme.tile),
        border: Border.all(color: AppColors.line),
      ),
      child: Icon(
        Icons.checkroom,
        size: 52,
        color: colour.computeLuminance() > .45 ? AppColors.ink : AppColors.white,
      ),
    );
  }
}
